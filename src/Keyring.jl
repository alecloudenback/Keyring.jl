module Keyring

include("core.jl")
include("Windows.jl")

"""
    DEFAULT_CREDENTIAL_STORE()::T<:AbstractCredentialStore

Returns the default credential store for the current system.

- Windows: [`Windows.WindowsCredentialManager`](@ref)
- macOS: TBD
- Linux: TBD

"""
DEFAULT_CREDENTIAL_STORE() =
    if Sys.islinux()
        # TODO
    elseif Sys.isapple()
        # TODO
    elseif Sys.iswindows()
        Windows.WindowsCredentialManager()
    end
# Write your package code here.

export get_credential, get_password, set_credential, set_password,
    Windows

end
