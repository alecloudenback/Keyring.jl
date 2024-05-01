module Windows
import ..AbstractCredential
import ..AbstractCredentialStore
import ..Credential
import ..get_credential, ..set_credential


const CRED_TYPE_GENERIC = 0x01
const CRED_PERSIST_LOCAL_MACHINE = 0x02

struct WindowsCredentialManager <: AbstractCredentialStore end

struct WindowsCredentialManagerCredential <: AbstractCredential
    flags::UInt32
    type::UInt32
    target_name::Ptr{UInt16}
    comment::Ptr{UInt16}
    last_written::UInt64
    credential_blob_size::UInt32
    credential_blob::Ptr{UInt8}
    persist::UInt32
    attribute_count::UInt32
    attributes::Ptr{Cvoid}
    target_alias::Ptr{UInt16}
    user_name::Ptr{UInt16}
end

function set_credential(store::WindowsCredentialManager, target::AbstractString, username::AbstractString, password::AbstractString)
    target_name = pointer(transcode(UInt16, target))
    username_ptr = pointer(transcode(UInt16, username))
    password_ptr = pointer(transcode(UInt16, password))
    password_size = sizeof(password) * 2

    cred = WindowsCredentialManagerCredential(0, CRED_TYPE_GENERIC, target_name, C_NULL, 0, password_size,
        password_ptr, CRED_PERSIST_LOCAL_MACHINE, 0, C_NULL, C_NULL,
        username_ptr)

    result = ccall((:CredWriteW, "advapi32"), UInt32,
        (Ref{WindowsCredentialManagerCredential}, UInt32),
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
            return Some(nothing)
        else
            error("CredRead failed with error code: $error_code")
        end
    end

    cred = unsafe_load(cred_ptr[])
    password_len = cred.credential_blob_size ÷ sizeof(Cwchar_t)
    password = unsafe_string(convert(Ptr{Cwchar_t}, cred.credential_blob), password_len)
    username_len = ccall(:wcslen, Csize_t, (Ptr{Cwchar_t},), cred.user_name)
    username = unsafe_string(convert(Ptr{Cwchar_t}, cred.user_name), username_len)

    credential = Credential(target, username, password)

    # Free the memory allocated by CredRead
    ccall((:CredFree, "advapi32"), Cvoid, (Ptr{Cvoid},), cred_ptr[])

    return credential
end

end