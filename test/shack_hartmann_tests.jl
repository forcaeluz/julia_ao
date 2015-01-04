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
function test_sensor_creation()
  print_with_color(:blue, "Testing shack hartmann sensor creation:\n")
  sensor = create_sensor()
  # To-do: Add oracles
end

function test_extract_phaseplate()
  print_with_color(:blue, "Testing extract_phase_plate()\n")
  sensor = create_sensor()
  phase = create_flat_phase_screen()
  plate = extract_phaseplate(sensor, 1, phase)
  # To-do: Add oracles
end

function test_compute_average_phaseplate_gradients()
  print_with_color(:blue, "Testing compute_average_phaseplate_gradients()\n")
  # Create a phase_plate with known gradient
  phase_plate = create_screen([-1.0, -1.0], [1.0, 1.0], [0.1, 0.1])
  for i = 1:length(phase_plate.x_pxl_centers), j = 1:length(phase_plate.y_pxl_centers)
    phase_plate.data[i, j] = phase_plate.x_pxl_centers[i] + phase_plate.y_pxl_centers[i]
  end
  (gx, gy) = compute_average_phaseplate_gradients(plate)
  @test_approx_eq gx 1.0
  @test_approx_eq gy 1.0
end

function test_compensate_phaseplate_tiptilt()
  print_with_color(:blue, "Testing compensate_phaseplate_tiptilt!()\n")
  #To-do: implement
end

function test_compute_imagelet_intensities()
  print_with_color(:blue, "Testing compute_imagelet_intensities()\n")
  #To-do: Implement actual test.
end
#########################################################################################
# Support functions
function create_sensor()
  config = ShackHartmannConfig(5, 0.4e-2, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  return sensor
end

function create_flat_phase_screen()

end
#########################################################################################
# Test plan execution
print_with_color(:green, "\nTesting ", tested_file, "\n")
test_sensor_creation()
#test_extract_phaseplate()
test_compute_average_phaseplate_gradients()
#test_compensate_phaseplate_tiptilt()
#test_compute_imagelet_intensities()
print_with_color(:green, tested_file, " has been tested \n")
