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

#########################################################################################
# Test functions
"""
  This function tests if the sensor can be created, and if the parameters result in the
  correct mirror properties.
"""
function test_sensor_creation()
  print_with_color(:blue, "Testing shack hartmann sensor creation\n")
  sensor = create_sensor()
  # To-do: Add oracles
end

"""
  This function tests if the right failure occurs when the mirror parameters are not
  correctly filled in.
"""
function test_invalid_sensor_creation()
  print_with_color(:blue, "Testing invalid shack hartmann sensor creation\n")
  # To-do: Add test code.
end

"""
  Tests the light intensity for each pixel in the CCD.
"""
function test_intensity_computation()
  print_with_color(:blue, "Testing intensity computation for flat screen\n")
  # To-do: Add test code.
end
#########################################################################################
# Support functions
function create_sensor()
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  return sensor
end

function create_flat_phase_screen()
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  return phase_screen
end
#########################################################################################
# Test plan execution
print_with_color(:green, "\nTesting ", tested_file, "\n")
test_sensor_creation()
test_invalid_sensor_creation()
print_with_color(:green, "File: ", tested_file, " has been tested \n")
