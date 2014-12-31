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

using Base.Test
using julia_ao

tested_file = "shack_hartman.jl"

function test_sensor_creation()
  print_with_color(:blue, "Testing shack hartmann sensor creation:\n")
  config = ShackHartmanConfig(10, 0.4e-2, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3,
                               630e-9, 4, compute_shackhartman_intensities, compute_cog_centroids)
  sensor = ShackHartmanSensor(config)
end

print_with_color(:green, "\nTesting ", tested_file, "\n")
test_sensor_creation()
print_with_color(:green, tested_file, " has been tested \n")
