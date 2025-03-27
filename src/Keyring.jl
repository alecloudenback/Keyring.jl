module Keyring

include("core.jl")
include("Mac.jl")
include("Windows.jl")

"""
    DEFAULT_CREDENTIAL_STORE()::T<:AbstractCredentialStore

Returns the default credential store for the current system.

- Windows: [`Windows.WindowsCredentialManager`](@ref)
- macOS: [`Mac.MacCredentialManager`](@ref)
- Linux: TBD

"""
DEFAULT_CREDENTIAL_STORE() =
if Sys.islinux()
    # TODO
elseif Sys.isapple()
    Mac.MacCredentialManager()
elseif Sys.iswindows()
    Windows.WindowsCredentialManager()
end

export get_credential, get_password, set_credential, set_password,
    Windows, Mac

end
