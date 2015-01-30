########################################################
# The MIT License (MIT)
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

include("shack_hartmann.jl")
include("screen.jl")

"""
  Calculates the centroids based on the Center of Gravity algorithm
"""
function calculate_cog_centroids(sensor::ShackHartmannSensor)
  lenslets = sensor.lenslet_positions
  centroids = Array(Float64, size(lenslets)[1], 2)
  x_length = sensor.configuration.inter_lenslet_distance
  y_length = sensor.configuration.inter_lenslet_distance
  image = sensor.intensity_screen
  for i = 1:size(lenslets)[1]
    x_start = lenslets[i, 2] - x_length / 2
    x_end = lenslets[i, 2] + x_length / 2
    y_start = lenslets[i, 3] - y_length / 2
    y_end = lenslets[i, 3] + y_length / 2

    x_selection = x_end .>= image.x_pxl_centers .>= x_start
    y_selection = y_end .>= image.y_pxl_centers .>= y_start

    x_values = image.x_pxl_centers[x_selection]
    y_values = image.y_pxl_centers[y_selection]
    imagelet = create_screen( [x_values[1], y_values[1]],
                              [x_values[end], y_values[end]],
                              image.pxl_size)

    imagelet.data = image.data[x_selection, y_selection]

    cog = calculate_imagelet_cog(imagelet)
    centroids[i, :] = cog
  end
  return centroids
end

"""
  Calculates the centroid for a specific lenslet.
"""
function  calculate_imagelet_cog(imagelet::Screen)
  intensity_sum = 0
  weighted_x_sum = 0
  weighted_y_sum = 0
  for i = 1:length(imagelet.x_pxl_centers), j = 1:length(imagelet.y_pxl_centers)
    weighted_x_sum = weighted_x_sum + imagelet.x_pxl_centers[i] * imagelet.data[i, j]
    weighted_y_sum = weighted_y_sum + imagelet.y_pxl_centers[j] * imagelet.data[i, j]
    intensity_sum = intensity_sum + imagelet.data[i, j]
  end
  return [weighted_x_sum, weighted_y_sum] ./ intensity_sum
end
