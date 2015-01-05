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


module julia_ao

include("deformable_mirror.jl")
include("screen.jl")
include("shack_hartmann.jl")
include("plotting.jl")

# package code goes here
export PztDmConfiguration,
        PztDm,
        compute_adhoc_influence,
        compute_adhoc_no_coupling_influence,
        compute_sync_influence,
        compute_gaussian_influence,
        compute_double_gaussian_influence,
        compute_modified_gaussian_influence,
        compute_dm_shape

export Screen,
        create_centered_screen,
        create_screen,
        interpolate_to_screen!

export ShackHartmannConfig,
        ShackHartmannSensor,
        compute_shackhartmann_intensities,
        extract_phaseplate,
        compute_average_phaseplate_gradients,
        compensate_phaseplate_tiptilt!,
        compute_imagelet_intensities,
        compensate_imagelet_tiptilt!
export plot_color_screen,
        plot_color_to_web

end # module
