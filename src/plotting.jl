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

using PyPlot
using Plotly

include("screen.jl")

function plot_color_screen(screen::Screen)
  x_start = screen.x_pxl_centers[1] - screen.pxl_size[1]/2
  x_end = screen.x_pxl_centers[end] + screen.pxl_size[1]/2
  y_start = screen.y_pxl_centers[1] - screen.pxl_size[2]/2
  y_end = screen.y_pxl_centers[end] + screen.pxl_size[2]/2
  x_bounds = x_start:screen.pxl_size[1]:x_end
  y_bounds = y_start:screen.pxl_size[2]:y_end
  plt = pcolor(x_bounds, y_bounds, screen.data)
  colorbar(plt)
  axis([x_start, x_end, y_start, y_end])
end


function plot_color_to_web(screen::Screen)
  # Replace with your own account info.
  Plotly.signin("Julia-Demo-Account", "hvkrsbg3uj")
  x_start = screen.x_pxl_centers[1] - screen.pxl_size[1]/2
  x_end = screen.x_pxl_centers[end] + screen.pxl_size[1]/2
  y_start = screen.y_pxl_centers[1] - screen.pxl_size[2]/2
  y_end = screen.y_pxl_centers[end] + screen.pxl_size[2]/2
  x_bounds = x_start:screen.pxl_size[1]:x_end
  y_bounds = y_start:screen.pxl_size[2]:y_end
  data = [
    [
      "x" => screen.x_pxl_centers,
      "y" => screen.y_pxl_centers,
      "z" => screen.data,
      "type" => "heatmap"
    ]
  ]
  response = Plotly.plot(data, ["filename" => "screen", "fileopt" => "overwrite"])
  plot_url = response["url"]
  return plot_url
end
