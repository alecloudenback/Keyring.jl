module Mac
import ..AbstractCredential
import ..AbstractCredentialStore
import ..Credential
import ..get_credential, ..set_credential

struct MacCredentialManager <: AbstractCredentialStore end

function set_credential(store::MacCredentialManager, target::String, username::String, secret::String)
    # First, check if credential already exists and delete it
    try
        delete_credential(store, target)
    catch
        # If credential doesn't exist, that's fine
    end

    # Use the security command to add the credential to macOS Keychain
    cmd = `security add-generic-password -a $username -s $target -w $secret`
    result = try
        success(cmd)
    catch e
        @warn "Failed to store credential: $e"
        return false
    end

    return
end

function get_credential(store::MacCredentialManager, target::String)
    # Get username
    username_cmd = `security find-generic-password -s $target -g`
    username_output = try
        read(pipeline(username_cmd, stderr = devnull), String)
    catch e
        return nothing
    end

    # Extract username from output
    username_match = match(r"\"acct\"<blob>=\"(.*?)\"", username_output)
    if username_match === nothing
        error("Could not find username for target '$target'")
    end
    username = username_match.captures[1]

    # Get password
    secret_cmd = `security find-generic-password -s $target -w`
    secret = try
        read(secret_cmd, String) |> strip
    catch e
        error("Failed to retrieve password for target '$target': $e")
    end

    return Credential(target, username, secret)
end

function delete_credential(store::MacCredentialManager, target::String)
    cmd = `security delete-generic-password -s $target`
    result = try
        success(cmd)
    catch e
        @warn "Failed to delete credential: $e"
        return false
    end

    return result
end

end # module
