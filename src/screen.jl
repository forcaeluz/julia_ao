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
  Screen: This is a type that holds image or phase information, and the location of the
  information in the real world.
"""
type Screen
  x_pxl_centers::FloatRange
  y_pxl_centers::FloatRange
  pxl_size::Array{Float64, 1}
  resolution::Array{Int64, 1}
  data::Array{Float64}
end

"""
  Function to create a screen with all the parameters given. The idea of the function is
  to do a sanity check on the parameters. Screens created without this function could not
  behave properly when plotted.
"""
function create_screen(x_centers::FloatRange, y_centers::FloatRange,
                       pxl_size::Array{Float64, 1}, resolution::Array{Int64, 1},
                       data)
  @assert length(x_centers) == resolution[1] "x_centers does not match resolution"
  @assert length(y_centers) == resolution[2] "y_centers does not match resolution"
  @assert size(data) == (resolution[1],resolution[2]) "Data size does not match resolution"
  screen = Screen(x_centers, y_centers, pxl_size, resolution, data)
  return screen
end

"""
  Function to create a "clean" screen, based on physical properties. The center
  of the screen is position (0,0).
"""
function create_centered_screen(physical_size::Array{Float64, 1},
                                resolution::Array{Int64, 1})
  pixel_size = physical_size ./ resolution
  x_start = -(physical_size[1] / 2 - pixel_size[1] / 2);
  x_end = (physical_size[1] / 2 - pixel_size[1] / 2);
  y_start = -(physical_size[2] / 2 - pixel_size[2] / 2);
  y_end = (physical_size[2] / 2 - pixel_size[2] / 2);
  x_centers = x_start:pixel_size[1]:x_end
  y_centers = y_start:pixel_size[2]:y_end
  data = zeros(length(x_centers), length(y_centers))
  screen = create_screen(x_centers, y_centers, pixel_size, resolution, data)
end

