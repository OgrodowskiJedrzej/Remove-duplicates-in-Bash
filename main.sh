#!/bin/bash

check_same_content() {
    local file1="$1"
    local file2="$2"
    if [ "$file1" != "$file2" ]; then
        if cmp -s "$file1" "$file2"; then
            echo "Files $file1 and $file2 have same content."
        fi
    fi
}

delete_duplicate_without_asking() {
    local file="$1"
    rm -f "$file"
}

delete_duplicate_with_asking() {
    local file="$1"
    rm -i "$file"
}


compare_files() {
    directory="$1"

    # Use find to get a list of all files (excluding directories) recursively
    find "$directory" -type f -print0 | while IFS= read -r -d '' file1; do
        while IFS= read -r -d '' file2; do
            # Compare files if they have different names
               check_same_content $file1 $file2
        done < <(find "$directory" -type f -print0)
    done
}


print_file_info() {
    local file="$1"
    
    if [ -e "$file" ]; then
        echo "File: $file"
        echo "Owner: $(stat -f '%Su' "$file")"
        echo "Group: $(stat -f '%Sg' "$file")"
        echo "Permissions: $(stat -f '%Lp' "$file")"
        echo "Last Modified: $(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$file")"
        echo "Size: $(stat -f '%z' "$file") bytes"
    else
        echo "File not found: $file"
    fi
}

compare_files "/Users/jendras/Prywatne/Books/"