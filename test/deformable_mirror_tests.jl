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

using Base.Test
using julia_ao


# Test actuator placement algorithm.
# Two things are tested: The number of actuators that are on the mirror and their position.
#
function test_actuator_positioning()
  println("Testing Actuator Positioning")
  configuration = PztDmConfiguration(6, 0.027, 0.01, compute_adhoc_influence, 0.15, 0.0, 0.1)
  mirror = PztDm(configuration)

  @test size(mirror.actuator_positions) == (24, 4)
  for i=1:24
    original_index = mirror.actuator_positions[i, 1]
    x_index = (original_index % 6)
    y_index = div(original_index, 6)
    if x_index != 0
      x_index = x_index - 1
    else
      x_index = 5
      y_index -= 1
    end
    @test mirror.actuator_positions[i, 4] <= 0.027
    @test_approx_eq mirror.actuator_positions[i, 2] (x_index * 0.01 - 0.025)
    @test_approx_eq mirror.actuator_positions[i, 3] (y_index * 0.01 - 0.025)
  end
end


# Compute the influence function for an actuator
# over the whole mirror. Note that the output is not checked. The tests
# only garantee that no errors are thrown with the call to the influence function.
function test_influence_function(influence_function::Function)
  println("Testing influence function: ", influence_function)
  configuration = PztDmConfiguration(6, 0.027, 0.01, influence_function, 0.15, 0.0, 0.1)
  mirror = PztDm(configuration)
  actuator_number = 1
  plot_size = 400
  influence_matrix = Array(Float64, plot_size, plot_size)
  mirror_radius = mirror.configuration.radius
  actuator_positions = mirror.actuator_positions
  for i=1:plot_size, j=1:plot_size
    pixel_position = compute_pixel_position(i, j, mirror_radius, plot_size)
    influence_matrix[i, j] = mirror.configuration.influence_function(mirror,
                                                         actuator_number,
                                                         pixel_position)

  end
end


function test_compute_dm_shape()
  println("Testing dm shape computation")
  configuration = PztDmConfiguration(6, 0.027, 0.01, compute_adhoc_influence, 0.15, 0.0, 0.1)
  mirror = PztDm(configuration)
  commands = ones(24, 1)
  result::Float64 = 0.0
  result = compute_dm_shape(mirror, commands, [0,0])
end

function compute_pixel_position(i, j, mirror_radius, plot_size)
  plot_center::Float64 = (plot_size / 2.0) + 0.5
  pixel_size = ( mirror_radius * 2 ) / plot_size
  x::Float64 = ( plot_center - j ) * pixel_size
  y::Float64 = ( plot_center - i ) * pixel_size
  return [x, y]
end

println("Testing deformable_mirror.jl")
test_actuator_positioning()
test_influence_function(compute_adhoc_influence)
test_influence_function(compute_adhoc_no_coupling_influence)
test_influence_function(compute_gaussian_influence)
test_influence_function(compute_modified_gaussian_influence)
test_influence_function(compute_double_gaussian_influence)
test_compute_dm_shape()

