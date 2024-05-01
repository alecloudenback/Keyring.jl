module Windows
import ..AbstractCredential
import ..AbstractCredentialStore
import ..Credential
import ..get_credential, ..set_credential

const CRED_TYPE_GENERIC = 0x01
const CRED_PERSIST_LOCAL_MACHINE = 0x02

"""
    WindowsCredentialManager <: AbstractCredentialStore

This interacts with the Windows Credential Manager via the `advapi32.dll` (Advanced Windows 32 Base API) library available on Windows systems.


"""
struct WindowsCredentialManager <: AbstractCredentialStore end

struct WindowsCredentialManagerCredential <: AbstractCredential
    flags::UInt32
    type::UInt32
    target_name::Ptr{Cwchar_t}
    comment::Ptr{Cwchar_t}
    last_written::UInt64
    credential_blob_size::UInt32
    credential_blob::Ptr{UInt8}
    persist::UInt32
    attribute_count::UInt32
    attributes::Ptr{Cvoid}
    target_alias::Ptr{Cwchar_t}
    user_name::Ptr{Cwchar_t}
end

function set_credential(store::WindowsCredentialManager, target::AbstractString, username::AbstractString, password::AbstractString)
    target_name = Base.unsafe_convert(Ptr{Cwchar_t}, Base.cwstring(target))
    username_ptr = Base.unsafe_convert(Ptr{Cwchar_t}, Base.cwstring(username))
    password_ptr = Base.unsafe_convert(Ptr{Cwchar_t}, Base.cwstring(password))
    password_size = (length(password) + 1) * sizeof(Cwchar_t)

    cred = WindowsCredentialManagerCredential(0, CRED_TYPE_GENERIC, target_name, C_NULL, 0, password_size,
        Base.unsafe_convert(Ptr{UInt8}, password_ptr), CRED_PERSIST_LOCAL_MACHINE, 0, C_NULL, C_NULL,
        username_ptr)

    result = ccall((:CredWriteW, "advapi32"), UInt32,
        (Ptr{WindowsCredentialManagerCredential}, UInt32),
        Ref(cred), 0)

    if result == 0
        error("CredWrite failed with error code: $(ccall(:GetLastError, stdcall, UInt32, ()))")
    end
end

function get_credential(store::WindowsCredentialManager, target::AbstractString)
    target_name = Base.cwstring(target)
    cred_ptr = Ref{Ptr{WindowsCredentialManagerCredential}}()

    result = ccall((:CredReadW, "advapi32"), UInt32,
        (Ptr{Cwchar_t}, UInt32, UInt32, Ref{Ptr{WindowsCredentialManagerCredential}}),
        target_name, CRED_TYPE_GENERIC, 0, cred_ptr)

    if result == 0
        error_code = ccall(:GetLastError, stdcall, UInt32, ())
        if error_code == 1168
            return nothing
        else
            error("CredRead failed with error code: $error_code")
        end
    end

    cred = unsafe_load(cred_ptr[])
    password_len = cred.credential_blob_size ÷ sizeof(Cwchar_t)
    password = unsafe_string(convert(Ptr{Cwchar_t}, cred.credential_blob), password_len)
    username_len = ccall(:wcslen, Csize_t, (Ptr{Cwchar_t},), cred.user_name) + 1
    username = unsafe_string(convert(Ptr{Cwchar_t}, cred.user_name), username_len)

    credential = Credential(rstrip(target, '\0'), rstrip(username, '\0'), rstrip(password, '\0'))

    # Free the memory allocated by CredRead
    ccall((:CredFree, "advapi32"), Cvoid, (Ptr{Cvoid},), cred_ptr[])

    return credential
end
end