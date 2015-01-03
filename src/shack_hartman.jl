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
function compute_shackhartman_intensities(sensor::ShackHartmannSensor, phase_screen::Screen)
  # Prepare
  image = sensor.intensity_screen
  dx = image.pxl_size[1]
  dy = image.pxl_size[2]
  lenslet_diameter = sensor.configuration.lenslet_diameter
  lambda = sensor.configuration.wave_length
  focal_distance = sensor.configuration.focal_distance
  support_factor = sensor.configuration.support_factor
  support_screen = create_support_screen(support_factor, lenslet_diameter,
                                         phase_screen.pxl_size)
  filter_screen = create_filter_screen(support_factor, lenslet_diameter,
                                       phase_screen.pxl_size)
  fft_screen = create_fft_screen(sensor)
  final_data = zeros(200, 200)
  for i = 1:size(sensor.lenslet_positions)[1]
    # Extract phase information inside lenslet
    x_position = sensor.lenslet_positions[i, 2]
    y_position = sensor.lenslet_positions[i, 3]

    phase_plate = extract_phaseplate([x_position, y_position],
                       lenslet_diameter, phase_screen)

    interpolate_to_screen!(support_screen, phase_plate)

    Uin = exp(im .* support_screen.data)
    Ulb = Uin .* filter_screen.data
    Uln = dx .* dy .* fftshift(fft(Ulb))

    fft_screen = create_fft_screen(sensor)
    fft_screen.data = abs2(Uln)
    fft_screen.x_pxl_centers = fft_screen.x_pxl_centers .+  x_position
    fft_screen.y_pxl_centers = fft_screen.y_pxl_centers .+  y_position
    interpolate_to_screen!(image, fft_screen)
    final_data = final_data + image.data
  end
  image.data = final_data ./ maximum(final_data)
  return image
end

function compute_cog_centroids(sensor::ShackHartmannSensor, intensity_screen::Screen)

end

"""

"""
function extract_phaseplate(lens_center, lenslet_diameter, incomming_screen)
  start_pos = Array(Float64, 2)
  end_pos = Array(Float64, 2)
  step = incomming_screen.pxl_size
  radius = lenslet_diameter / 2
  start_pos = lens_center .- radius
  end_pos = lens_center .+ radius

  plate = create_screen(start_pos, end_pos, step)
  interpolate_to_screen!(plate, incomming_screen)
  return plate
end


function create_support_screen(support_factor, lenslet_diameter, pixel_size)
  support_radius = lenslet_diameter * support_factor / 2
  support_start = [-support_radius, -support_radius]
  support_end = [support_radius + pixel_size[1] / 2, support_radius + pixel_size[2] / 2]
  support_screen = create_screen(support_start, support_end, pixel_size)
  return support_screen
end

function create_filter_screen(support_factor, lenslet_diameter, pixel_size)
  radius = lenslet_diameter / 2
  screen = create_support_screen(support_factor, lenslet_diameter, pixel_size)
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

"""
function create_fft_screen(sensor::ShackHartmannSensor)
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
  fft_screen = create_screen(fft_start, fft_end, fft_step)
  return fft_screen
end
