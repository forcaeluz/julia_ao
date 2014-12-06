module julia_ao

include("deformable_mirror.jl")

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

end # module
