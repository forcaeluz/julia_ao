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
  Compute the slopes for a SH sensor based on the computed centroids.
"""
function calculate_slopes(sensor::ShackHartmannSensor, centroids)
  delta = sensor.lenslet_positions[:,2:3] - centroids
  println(delta)
  slopes = delta ./ sensor.configuration.focal_distance
  return slopes
end

"""
  Calculates the centroids based on the Center of Gravity algorithm
"""
function calculate_cog_centroids(sensor::ShackHartmannSensor)
  calculate_generic_centroids(sensor, calculate_imagelet_cog)
end

"""
  Calculates the centroids based on the Weighted Center of Gravity algorithm.
  To-do: Add the possibility to modify parameters from the algorithm.
"""
function calculate_wcog_centroids(sensor::ShackHartmannSensor)
  calculate_generic_centroids(sensor, calculate_imagelet_wcog)
end

"""
  Calculates the centroids based on the Intensity Weighted Centroid algorithm.
  To-do: Add the possibility to modify parameters from the algorithm.
"""
function calculate_iwc_centroids(sensor::ShackHartmannSensor)
  calculate_generic_centroids(sensor, calculate_imagelet_iwc)
end


"""
  Calculates the center of gravity for a specific lenslet.
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

"""
  Calculates the Weighted Center of Gravity for a specific lenslet.
"""
function calculate_imagelet_wcog(imagelet::Screen)
  x_c = (imagelet.x_pxl_centers[end] - imagelet.x_pxl_centers[1]) / 2
  y_c = (imagelet.y_pxl_centers[end] - imagelet.y_pxl_centers[1]) / 2
  intensity_sum = 0
  weighted_x_sum = 0
  weighted_y_sum = 0
  for i = 1:length(imagelet.x_pxl_centers), j = 1:length(imagelet.y_pxl_centers)
    x = imagelet.x_pxl_centers[i]
    y = imagelet.y_pxl_centers[j]
    intensity = imagelet.data[i, j]
    weight = calculate_gaussian_weight(x, x_c, y, y_c, 1)
    weighted_x_sum = weighted_x_sum +  (x - x_c) * intensity * weight
    weighted_y_sum = weighted_y_sum +  (y - y_c) * intensity * weight
    intensity_sum = intensity_sum + weight * intensity
  end
  return [weighted_x_sum, weighted_y_sum] ./ intensity_sum .+ [x_c, y_c]
end

"""
  Calculates the Intensity Weighted Centroid for a specific lenslet.
"""
function calculate_imagelet_iwc(imagelet::Screen)
  x_c = (imagelet.x_pxl_centers[end] - imagelet.x_pxl_centers[1]) / 2
  y_c = (imagelet.y_pxl_centers[end] - imagelet.y_pxl_centers[1]) / 2
  intensity_sum = 0
  weighted_x_sum = 0
  weighted_y_sum = 0
  for i = 1:length(imagelet.x_pxl_centers), j = 1:length(imagelet.y_pxl_centers)
    x = imagelet.x_pxl_centers[i]
    y = imagelet.y_pxl_centers[j]
    intensity = imagelet.data[i, j]
    weight = intensity
    weighted_x_sum = weighted_x_sum +  (x - x_c) * intensity * weight
    weighted_y_sum = weighted_y_sum +  (y - y_c) * intensity * weight
    intensity_sum = intensity_sum + weight * intensity
  end
  return [weighted_x_sum, weighted_y_sum] ./ intensity_sum .+ [x_c, y_c]
end

"""
  Calculates the Gaussian Weight for the traditional WCoG.
"""
function calculate_gaussian_weight(x, xc, y, yc, sigma)
  tmp_x = ((x - xc) ^ 2) / (2 * (sigma^2))
  tmp_y = ((y - yc) ^ 2) / (2 * (sigma^2))
  weight = (1 / (2 * pi * (sigma^2))) * exp (-tmp_x - tmp_y)
  return weight
end

"""
  Calculates the centroids for all the lenslets according to algorithms
"""
function calculate_generic_centroids(sensor::ShackHartmannSensor, algorithm::Function)
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
    cog = algorithm(imagelet)
    centroids[i, :] = cog
  end
  return centroids
end
