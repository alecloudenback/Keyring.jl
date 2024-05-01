abstract type AbstractCredentialStore end
abstract type AbstractCredential end


"""
    Credential{U,T,V}(target,username,secret) <: AbstractCredential

A credential object that stores the target, username, and secret. Access the fields
using the dot syntax, e.g. `c.target`, `c.username`, `c.secret`.
"""
struct Credential{U,T,V} <: AbstractCredential
    target::T
    username::U
    secret::V
end

function Base.show(io::IO, c::Credential)
    print(io, "Credential( target: $(c.target), username: $(c.username), secret: ****)")
end

"""
    get_credential(target::AbstractString)
    get_credential(store::AbstractCredentialStore, target::AbstractString)

Returns either a [Credential](@ref) or `Some(nothing)` if the credential is not found.

If not given, `store` defaults to the value of [`DEFAULT_CREDENTIAL_STORE`](@ref).

# Examples
```julia_repl
julia> set_credential("my_target", "my_username", "my_secret")
julia> c = get_credential("my_target")
```
"""
function get_credential(target)
    return get_credential(DEFAULT_CREDENTIAL_STORE(), target)
end

"""
    set_credential(target::AbstractString, username::AbstractString, secret::AbstractString)
    set_credential(store::AbstractCredentialStore, target::AbstractString, username::AbstractString, secret::AbstractString)

Sets the value and returns `nothing`.

If not given, `store` defaults to the value of [`DEFAULT_CREDENTIAL_STORE`](@ref).
"""
function set_credential(target, username, secret)
    return set_credential(DEFAULT_CREDENTIAL_STORE(), target, username, secret)
end