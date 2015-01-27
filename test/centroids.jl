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

tested_file = "centroids.jl"

# Test Functions
function test_cog_centroid()
  print_with_color(:blue, "Testing calculate_cog_centroid() for single lenslet\n")
end

function test_cog_centroid_multiple_lenslets()
  print_with_color(:blue, "Testing calculate_cog_centroid() for multiple lenslets\n")
end


# Test Script
# Test plan execution
print_with_color(:green, "\nTesting ", tested_file, "\n")
test_cog_centroid()
test_cog_centroid_multiple_lenslets()
print_with_color(:green, tested_file, " has been tested \n")
