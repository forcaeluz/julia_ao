########################################################
# The MIT License (MIT)
# Copyright (c) 2014 Mario Voorsluys (forcaeluz)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
########################################################

include("screen.jl")
include("geometries.jl")
include("utilities.jl")

"""
  Configuration parameters for a Shack-Hartmann Sensor.
  Note that this configuration is only for a square sensor with
  a square grid.
  The parameters are:
    - lenslets_in_width: Number of lenslets in the width
    - width: The lenslet array and sensor width
    - resolution: A square sensor is assumed, so the resolution in both directions
    - inter_lenslet_distance: Distance between the centers of two lenslets (same row or
      colum)
    - lenslet_diameter: Diameter of the lens
    - focal_length: Focal length of the lens
    - wave_length: Wavelength of the light we are checking/simulating.
    - support_factor: Used in the calculation of the front
  Two functions are parameters as well:
    - compute_intensities: Algorithm to compute the normalized intensity on the CCD based
      on a phase_screen.
    - compute_centroid: Computes the centroids for each lenslet based on the intensity
      readings from the CCD.
"""
type ShackHartmannConfig
  #Parameters
  lenslets_in_width::Int64
  width::Float64
  resolution::Int64
  inter_lenslet_distance::Float64
  lenslet_diameter::Float64
  focal_distance::Float64
  wave_length::Float64
  support_factor::Float64
  #Functions
  compute_intensities::Function
  compute_centroid::Function
end

"""
 The Shack-Hartmann Sensor object itself.
 It contains the configuration, geometry information and an intensity screen, containing
 the image obtained from the image. From the image the slopes can be calculated.
"""
type ShackHartmannSensor
  #Parameters
  configuration::ShackHartmannConfig
  lenslet_positions::Array
  intensity_screen::Screen
  ShackHartmannSensor(configuration::ShackHartmannConfig) =
    initialize_shackhartmansensor( new(configuration ) )
end

"""
  Function to initialize the sensor, based on the configuration object given as
  parameter to the function.
"""
function initialize_shackhartmansensor(sensor::ShackHartmannSensor)
  # Compute lenslet positions
  pitch = sensor.configuration.inter_lenslet_distance
  lenslet_diam = sensor.configuration.lenslet_diameter
  lenslets_in_width = sensor.configuration.lenslets_in_width
  width = sensor.configuration.width
  resolution = sensor.configuration.resolution
  sensor.lenslet_positions = computer_lenslet_squaregrid(pitch, lenslet_diam,
                                                         lenslets_in_width, width)
  sensor.intensity_screen = create_centered_screen([width, width],
                                                   [resolution, resolution])
  return sensor
end

"""
  Function that returns the geometry information about the lenslet array. It makes some
  "sanity" checks and then compute the geometry.
"""
function computer_lenslet_squaregrid(pitch, lenslet_diam, lenslets_in_width, width)
  @assert pitch >= lenslet_diam
  @assert width >= (lenslets_in_width - 1) * pitch + lenslet_diam
  centers = compute_squaregrid_centers(pitch, lenslets_in_width)
  return centers;
end

"""
  Function to compute the image obtained from a SH sensor. The implementation is based on
  the implementation from PyAo and Yao.
  The algorithm basically uses a numerical approximation of the Fraunhofer Approximation
  to compute the PSF for each lenslet.
"""
function compute_shackhartmann_intensities(sensor::ShackHartmannSensor, phase_screen::Screen)
  # Assert the phase screen and image screen dimensions match
  @assert sensor.intensity_screen.x_pxl_centers == phase_screen.x_pxl_centers
  @assert sensor.intensity_screen.y_pxl_centers == phase_screen.y_pxl_centers

  # Prepare
  support_screen = create_support_screen(sensor)
  filter_screen = create_filter_screen(sensor)

  for i = 1:size(sensor.lenslet_positions)[1]
    # Extract the phase-plate
    phase_plate = extract_phaseplate(sensor, i, phase_screen)
    # Compute phase-plate average gradients
    (x_grad, y_grad) = compute_average_phaseplate_gradients(phase_plate)
    # Compensate for tip-tilt in phase-plate
    compensate_phaseplate_tiptilt!(phase_plate, x_grad, y_grad)
    # Interpolate phase-plate into support screen
    interpolate_to_screen!(support_screen, phase_plate)
    # Compute intensities in the imagelet-screen
    imagelet = compute_imagelet_intensities(support_screen, filter_screen, sensor)
    # Compensate tip-tilt in imagelet-screen
    compensate_imagelet_tiptilt!(imagelet, sensor, x_grad, y_grad)
    # Interpolate and add imagelet-screen to image-screen
    insert_imagelet_intto_image!(sensor, imagelet, i)
  end
  final_image = sensor.intensity_screen.data
  final_image = final_image ./ maximum(final_image)
  sensor.intensity_screen.data = final_image
  return sensor.intensity_screen
end

"""
  Extract the phase information from the big screen for the specific lenslet.
"""
function extract_phaseplate(sensor::ShackHartmannSensor, lens_number::Int64,
                            phase_screen::Screen)
  lenslet_diameter = sensor.configuration.lenslet_diameter
  start_pos = Array(Float64, 2)
  end_pos = Array(Float64, 2)
  lens_center = sensor.lenslet_positions[lens_number, 2:3]

  step = phase_screen.pxl_size
  radius = lenslet_diameter / 2
  start_pos = lens_center .- radius
  end_pos = lens_center .+ radius

  plate = create_screen(start_pos, end_pos, step)
  interpolate_to_screen!(plate, phase_screen)
  return plate
end

"""
  Compute the average gradients. This is used to improve the quality
  of the numerical approximation of the computations.
"""
function compute_average_phaseplate_gradients(phase_plate::Screen)
  (Gx, Gy) = calculate_2d_gradient(phase_plate.data, phase_plate.pxl_size[1],
                                   phase_plate.pxl_size[2])
  gx = mean(Gx)
  gy = mean(Gy)
  return gx, gy
end

"""
  Compensates the average tip/tilt in the phase_plate.
"""
function compensate_phaseplate_tiptilt!(phase_plate::Screen, gradient_x::Float64, gradient_y::Float64)
  for i = 1:length(phase_plate.x_pxl_centers), j = 1:length(phase_plate.y_pxl_centers)
    x_pos = phase_plate.x_pxl_centers[i]
    y_pos = phase_plate.y_pxl_centers[j]
    new_data = phase_plate.data[i, j] - (x_pos * gradient_x + y_pos * gradient_y)
    phase_plate.data[i, j] = new_data
  end
end

"""
  Compute the intensities on the focal plane for a specific lenslet.
"""
function compute_imagelet_intensities(support_screen::Screen, filter_screen::Screen,
                                      sensor::ShackHartmannSensor)
  dx = sensor.intensity_screen.pxl_size[1]
  dy = sensor.intensity_screen.pxl_size[1]
  Uin = exp(im .* support_screen.data)
  Ulb = Uin .* filter_screen.data
  Uln = dx .* dy .* fftshift(fft(Ulb))

  imagelet_screen = create_fft_screen(sensor)
  imagelet_screen.data = abs2(Uln)
  return imagelet_screen
end

"""

"""
function compensate_imagelet_tiptilt!(imagelet::Screen, sensor::ShackHartmannSensor,
                                      gradient_x::Float64, gradient_y::Float64)
  focal_distance = sensor.configuration.focal_distance
  k = 2 * pi * sensor.configuration.wave_length
  theta = arctan(gradient_x / k)
  phi = arctan(gradient_y / k)
  x_shift = tan(theta) * focal_distance
  y_shift = tan(phi) * focal_distance

  imagelet.x_pxl_centers = imagelet.x_pxl_centers .+ x_shift
  imagelet.y_pxl_centers = imagelet.y_pxl_centers .+ y_shift
end

function insert_imagelet_intto_image!(sensor::ShackHartmannSensor, imagelet::Screen,
                                      imagelet_number::Int64)
  image = sensor.intensity_screen
  old_data = image.data
  imagelet_center = sensor.lenslet_positions[imagelet_number, 2:3]
  imagelet.x_pxl_centers = imagelet.x_pxl_centers .+ imagelet_center[1]
  imagelet.y_pxl_centers = imagelet.y_pxl_centers .+ imagelet_center[2]
  interpolate_to_screen!(image, imagelet)
  image.data = image.data + old_data
end

"""
  Create a support screen. This screen will be used to resample the phase data
  for each lenslet.
"""
function create_support_screen(sensor::ShackHartmannSensor)
  lenslet_diameter = sensor.configuration.lenslet_diameter
  support_factor = sensor.configuration.support_factor
  pixel_size = sensor.intensity_screen.pxl_size

  support_radius = lenslet_diameter * support_factor / 2
  support_start = [-support_radius, -support_radius]
  support_end = [support_radius + pixel_size[1] / 2, support_radius + pixel_size[2] / 2]
  support_screen = create_screen(support_start, support_end, pixel_size)
  return support_screen
end

"""
  Create a screen that will be used as a filter for each lenslet. Assuming a circle
  lenslet.
"""
function create_filter_screen(sensor::ShackHartmannSensor)
  radius = sensor.configuration.lenslet_diameter / 2
  screen = create_support_screen(sensor)
  for i = 1:length(screen.x_pxl_centers), j = 1:length(screen.y_pxl_centers)
    x = screen.x_pxl_centers[i]
    y = screen.x_pxl_centers[j]
    distance = sqrt(x^2 + y^2)
    if distance < radius
      screen.data[i, j] = 1
    end
  end
  return screen
end

"""
  Creates a screen that will be used to store the image for a single lenslet.
"""
function create_imagelet_screen(sensor::ShackHartmannSensor)
  lambda = sensor.configuration.wave_length
  focal_distance = sensor.configuration.focal_distance
  support_factor = sensor.configuration.support_factor
  lenslet_diameter = sensor.configuration.lenslet_diameter
  support_diameter = support_factor * lenslet_diameter
  pixel_size = sensor.intensity_screen.pxl_size

  xfft_limit = (lambda * focal_distance / pixel_size[1]) / 2
  yfft_limit = (lambda * focal_distance / pixel_size[2]) / 2
  dfft = lambda * focal_distance / support_diameter
  fft_start = [-xfft_limit, -yfft_limit]
  fft_end = [xfft_limit + dfft/2, yfft_limit + dfft/2]
  fft_step = [dfft, dfft]
  imagelet_screen = create_screen(fft_start, fft_end, fft_step)
  return imagelet_screen
end
