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

include("../src/deformable_mirror.jl")

# First test: Test actuator placement algorithm.
# Two things are tested: The number of actuators that are on the mirror and their position.
#
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


# Second test: Compute the influence function for an actuator
# over the whole mirror.


# Third test: Test the multiple modelling functions, with and without coupling
#



# Fourth test:
#
