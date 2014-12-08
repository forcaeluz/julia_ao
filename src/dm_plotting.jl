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
#
#
#
########################################################
using PyPlot

include("deformable_mirror.jl")

function plot_dm_influence(actuator_number::Int64)
  configuration = PztDmConfiguration(6, 0.05, 0.01, compute_adhoc_influence, 0.15, 0.0, 0.1);
  mirror = PztDm(configuration)
  plot_size = 400
  influence_matrix = Array(Float64, plot_size, plot_size)
  mirror_radius = configuration.radius
  for i=1:plot_size, j=1:plot_size
    pixel_position = compute_pixel_position(i, j, mirror_radius, plot_size)
    influence_matrix[i, j] = mirror.configuration.influence_function(mirror,
                                                       actuator_number,
                                                       pixel_position)

  end
  #pcolor(influence_matrix)
  plot_surface([1:plot_size], [1:plot_size], influence_matrix, cmap=get_cmap("coolwarm"))
end

function compute_pixel_position(i, j, mirror_radius, plot_size)
  plot_center::Float64 = (plot_size / 2.0) + 0.5
  pixel_size = ( mirror_radius * 2 ) / plot_size
  x::Float64 = ( plot_center - j ) * pixel_size
  y::Float64 = ( plot_center - i ) * pixel_size
  return [x, y]
end
