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

function clip(variable, min, max)
  returnValue = variable
  if(variable > max)
    returnValue = max
  elseif(variable < min)
    returnValue = min
  end
  return returnValue
end

function calculate_2d_gradient(data::Array{Float64, 2}, dx, dy)
  gradient_x = zeros(size(data))
  gradient_y = zeros(size(data))

  for i = 1:size(data)[1]
    gradient_x[:,i] = gradient(data[:,i], dx)
  end

  for j = 1:size(data)[2]
    gradient_y[j,:] = gradient(data[j,:][:], dy)
  end
  return gradient_x, gradient_y
end
