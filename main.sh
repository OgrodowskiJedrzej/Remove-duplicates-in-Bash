#!/bin/bash

check_same_content() {
    local file1="$1"
    local file2="$2"

    if cmp -s "$file1" "$file2"; then
        echo "Files $file1 and $file2 have same content."
    fi
}

get_files_to_compare() {
    directory="$1"
    files=("$directory"/*)

    for ((i = 0; i < ${#files[@]}; i++)); do
        for ((j = i + 1; j < ${#files[@]}; j++)); do
            file1="${files[$i]}"
            file2="${files[$j]}"

            check_same_content $file1 $file2
        done
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

get_files_to_compare "/Users/jendras/Prywatne/Books/"