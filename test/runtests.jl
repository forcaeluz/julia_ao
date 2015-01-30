using Base.Test

include("runtests_private.jl")
workspace()
include("deformable_mirror_tests.jl")
include("screen_tests.jl")
include("shack_hartmann_tests.jl")
