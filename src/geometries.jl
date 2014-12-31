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

"""
  This function computers the centers for elements in a square grid.
  It returns an array with the following information:
  - Element number
  - Element X center
  - Element Y center
  - Element's distance to the grid center.
"""
function compute_squaregrid_centers(pitch, elements_x_direction)
  centers = Array(Float64, elements_x_direction ^ 2, 4)
  range = (elements_x_direction - 1) * pitch / 2
  for i = 1:elements_x_direction, j = 1:elements_x_direction
    element_number = j + (i - 1)*elements_x_direction
    x_distance = (j - 1) * pitch  - range
    y_distance = (i - 1) * pitch  - range
    abs_distance = sqrt(x_distance^2 + y_distance ^2)
    centers[element_number, 1] = element_number
    centers[element_number, 2] = x_distance
    centers[element_number, 3] = y_distance
    centers[element_number, 4] = abs_distance
  end
  return centers
end
