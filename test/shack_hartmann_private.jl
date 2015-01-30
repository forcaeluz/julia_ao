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

tested_file = "shack_hartmann.jl"

include(string("../src/", tested_file))

function test_extract_phaseplate()
  print_with_color(:blue, "Testing extract_phase_plate\n")
  sensor = create_sensor()
  phase = create_flat_phase_screen()
  plate = extract_phaseplate(sensor, 1, phase)
  # Check if size of the plate is as expected.
  @test_approx_eq plate.x_pxl_centers -7.7e-4:7.7e-6:-4.7e-4
  @test_approx_eq plate.y_pxl_centers -7.7e-4:7.7e-6:-4.7e-4
end

function test_compute_average_phaseplate_gradients()
  print_with_color(:blue, "Testing compute_average_phaseplate_gradients\n")
  # Create a phase_plate with known gradient
  phase_plate = create_screen([-1.0, -1.0], [1.0, 1.0], [0.1, 0.1])
  for i = 1:length(phase_plate.x_pxl_centers), j = 1:length(phase_plate.y_pxl_centers)
    phase_plate.data[i, j] = phase_plate.x_pxl_centers[i] + phase_plate.y_pxl_centers[j]
  end
  (gx, gy) = compute_average_phaseplate_gradients(phase_plate)
  @test_approx_eq gx 1.0
  @test_approx_eq gy 1.0
end

function test_compensate_phaseplate_tiptilt()
  print_with_color(:blue, "Testing compensate_phaseplate_tiptilt!()\n")
  phase_plate = create_screen([-1.0, -1.0], [1.0, 1.0], [0.1, 0.1])
  for i = 1:length(phase_plate.x_pxl_centers), j = 1:length(phase_plate.y_pxl_centers)
    phase_plate.data[i, j] = phase_plate.x_pxl_centers[i] + phase_plate.y_pxl_centers[j]
  end
  compensate_phaseplate_tiptilt!(phase_plate, 1.0, 1.0)

  for i = 1:length(phase_plate.x_pxl_centers), j = 1:length(phase_plate.y_pxl_centers)
    @test_approx_eq phase_plate.data[i, j] 0
  end
end

function test_compute_imagelet_intensities()
  print_with_color(:yellow, "Testing compute_imagelet_intensities()\n")
  #To-do: Implement actual test.
end

function test_compensate_imagelet_tiptilt()
  print_with_color(:blue, "Testing compensate_imagelet_tiptilt!()\n")
  sensor = create_sensor()
  screen = create_centered_screen([0.308e-4, 0.308e-4],[40, 40])
  compensate_imagelet_tiptilt!(screen, sensor, 0.1, 0.2)
  @test_approx_eq screen.x_pxl_centers ((-1.5015e-5:7.7e-7:1.501501e-5) + 1.804817055e-10)
  @test_approx_eq screen.y_pxl_centers ((-1.5015e-5:7.7e-7:1.501501e-5) + 3.609634109e-10)
end

function test_insert_imagelet_into_image()
  print_with_color(:blue, "Testing insert_imagelet_into_image()\n")
  sensor = create_sensor()
  imagelet = create_centered_screen([3.08e-4, 3.08e-4],[40, 40])
  insert_imagelet_intto_image!(sensor, imagelet, 1)
  # To-do: Add oracles. For now the only check is if the call does not return any errors.
  # This test should be data-driven.
end

function test_create_support_screen()
  print_with_color(:blue, "Testing create_support_screen()\n")
  sensor = create_sensor()
  test_screen = create_support_screen(sensor)
  @test_approx_eq test_screen.pxl_size [7.7e-6 7.7e-6]
  @test_approx_eq test_screen.x_pxl_centers -0.6e-3:7.7e-6:0.60335e-3
  @test_approx_eq test_screen.y_pxl_centers -0.6e-3:7.7e-6:0.60335e-3
  @test size(test_screen.data) == (157, 157)
end

function test_create_filter_screen()
  print_with_color(:blue, "Testing create_filter_screen()\n")
  sensor = create_sensor()
  test_screen = create_filter_screen(sensor)
  @test_approx_eq test_screen.pxl_size [7.7e-6 7.7e-6]
  @test_approx_eq test_screen.x_pxl_centers -0.6e-3:7.7e-6:0.60335e-3
  @test_approx_eq test_screen.y_pxl_centers -0.6e-3:7.7e-6:0.60335e-3
  @test size(test_screen.data) == (157, 157)
  radius = 0.15e-3

  for i = 1:length(test_screen.x_pxl_centers), j = 1:length(test_screen.y_pxl_centers)
    x = test_screen.x_pxl_centers[i]
    y = test_screen.x_pxl_centers[j]
    distance = sqrt(x^2 + y^2)
    if distance < radius
      @test test_screen.data[i, j] == 1
    else
      @test test_screen.data[i, j] == 0
    end
  end
end

function test_create_imagelet_screen()
  print_with_color(:blue, "Testing create_imagelet_screen()\n")
  sensor = create_sensor()
  test_screen = create_imagelet_screen(sensor)
  @test_approx_eq test_screen.pxl_size [9.45e-6 9.45e-6]
  @test_approx_eq test_screen.x_pxl_centers -0.73636363636e-3:9.45e-6:(0.736e-3+4.725e-6)
  @test_approx_eq test_screen.y_pxl_centers -0.73636363636e-3:9.45e-6:(0.736e-3+4.725e-6)
  @test size(test_screen.data) == (157, 157)
end

#########################################################################################
# Support functions
"""

"""
function create_sensor()
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  return sensor
end

"""

"""
function create_flat_phase_screen()
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  return phase_screen
end

#########################################################################################
# Test plan execution
print_with_color(:green, "\nTesting ", tested_file, "\n")
test_extract_phaseplate()
test_compute_average_phaseplate_gradients()
test_compensate_phaseplate_tiptilt()
test_compute_imagelet_intensities()
test_compensate_imagelet_tiptilt()
test_insert_imagelet_into_image()
test_create_support_screen()
test_create_filter_screen()
test_create_imagelet_screen()
print_with_color(:green, "File: ", tested_file, " has been tested \n")
