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

tested_file = "centroiding.jl"

#########################################################################################
# Test Functions
function test_calculate_cog_centroids()
  print_with_color(:blue, "Testing calculate_cog_centroids()\n")
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  sensor.configuration.compute_intensities(sensor, phase_screen)
  cog = calculate_cog_centroids(sensor)

  lenslets = sensor.lenslet_positions
  for i = 1:size(lenslets)[1]
    @test_approx_eq_eps cog[i, 1] lenslets[i, 2] 2e-6
    @test_approx_eq_eps cog[i, 2] lenslets[i, 3] 2e-6
  end
end

function test_calculate_wcog_centroids()
  print_with_color(:blue, "Testing calculate_wcog_centroids()\n")
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  sensor.configuration.compute_intensities(sensor, phase_screen)
  cog = calculate_wcog_centroids(sensor)

  lenslets = sensor.lenslet_positions
  for i = 1:size(lenslets)[1]
    @test_approx_eq_eps cog[i, 1] lenslets[i, 2] 2e-6
    @test_approx_eq_eps cog[i, 2] lenslets[i, 3] 2e-6
  end
end

function test_calculate_iwc_centroids()
  print_with_color(:blue, "Testing calculate_iwc_centroids()\n")
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  sensor.configuration.compute_intensities(sensor, phase_screen)
  cog = calculate_iwc_centroids(sensor)

  lenslets = sensor.lenslet_positions
  for i = 1:size(lenslets)[1]
    @test_approx_eq_eps cog[i, 1] lenslets[i, 2] 2e-6
    @test_approx_eq_eps cog[i, 2] lenslets[i, 3] 2e-6
  end
end

function test_calculate_slopes()
  print_with_color(:blue, "Testing calculate_slopes()\n")
  config = ShackHartmannConfig(5, 0.00154, 200, 10e-6 + 0.3e-3, 0.3e-3, 18e-3, 630e-9, 4,
                               compute_shackhartmann_intensities)
  sensor = ShackHartmannSensor(config)
  phase_screen = create_centered_screen([0.00154, 0.00154], [200, 200])
  sensor.configuration.compute_intensities(sensor, phase_screen)
  cog = calculate_cog_centroids(sensor)
  slopes = compute_slopes(sensor, cog)
    for i = 1:25
    @test_approx_eq_eps slopes[i, 1] 0 2e-4
    @test_approx_eq_eps slopes[i, 2] 0 2e-4
  end
end
#########################################################################################
# Support functions

#########################################################################################
# Test plan execution
print_with_color(:green, "\nTesting ", tested_file, "\n")
test_calculate_cog_centroids()
test_calculate_wcog_centroids()
test_calculate_slopes()
print_with_color(:green, "File: ", tested_file, " has been tested \n")
