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
  Configuration parameters for a ShackHartmanSensor.
  Note that this configuration is only for a square sensor with
  a square grid.
  The parameters are:
  - lenslets_in_width: Number of lenslets in the width
  - inter_lenslet_distance: Distance between the centers of two lenslets
  - resolution: Number of pixels in width for the sensor
  - focal_length:
  - lenslet_diameter:
  - wave_length:
  - width:
  - support_factor:

  Two functions are parameters as well:
  - compute_intensities: Algorithm to compute the normalized intensity on the CCD based
  on a phase_screen.
  - compute_centroid: Computes the centroids for each lenslet based on the intensity readings
  from the CCD.
"""
type ShackHartmanConfig
  #Parameters
  lenslets_in_width::Int64
  width::Float64
  resolution::Int64
  inter_lenslet_distance::Float64
  lenslet_diameter::Float64
  focal_length::Float64
  wave_length::Float64
  support_factor::Float64

  #Functions
  compute_intensities::Function
  compute_centroid::Function
end

"""

"""
type ShackHartmanSensor
  #Parameters
  configuration::ShackHartmanConfig
  lenslet_positions::Array
  intensity_screen::Screen
  ShackHartmanSensor(configuration::ShackHartmanConfig) = initialize_shackhartmansensor( new(configuration ) )
end

"""

"""
function initialize_shackhartmansensor(sensor::ShackHartmanSensor)
  # Compute lenslet positions
  pitch = sensor.configuration.inter_lenslet_distance
  lenslet_diam = sensor.configuration.lenslet_diameter
  lenslets_in_width = sensor.configuration.lenslets_in_width
  width = sensor.configuration.width
  resolution = sensor.configuration.resolution;
  sensor.lenslet_positions = computer_lenslet_squaregrid(pitch, lenslet_diam, lenslets_in_width, width)
  sensor.intensity_screen = create_centered_screen([width, width], [resolution, resolution])
  return sensor
end

function computer_lenslet_squaregrid(pitch, lenslet_diam, lenslets_in_width, width)
  @assert pitch > lenslet_diam
  @assert width > (lenslets_in_width - 1) * pitch + lenslet_diam
  centers = compute_squaregrid_centers(pitch, lenslets_in_width)
  return centers;
end

function compute_shackhartman_intensities(sensor::ShackHartmanSensor, phase_screen::Screen)
  # Extract phase information inside lenslet

  # Compute FFT

  # Intensity

end

function compute_cog_centroids(sensor::ShackHartmanSensor, intensity_screen::Screen)

end

"""

"""
function extract_phaseplate()


end
