#!/bin/bash

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

check_same_name() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$(basename "$file1")" = "$(basename "$file2")" ]; then
        echo "Files $file1 and $file2 have same name."
        if [ "$mode" = "-f" ]; then
            rm -f "$file1"
        fi
        if [ "$mode" = "-i" ]; then
            rm -i "$file1"
        fi
    fi 
}

check_same_content() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$file1" != "$file2" ]; then
        if cmp -s "$file1" "$file2"; then
            echo "Files $file1 and $file2 have same content."
            print_file_info $file1
            echo " "
            print_file_info $file2
               if [ "$mode" = "-f" ]; then
                    rm -f "$file1"
               fi
               if [ "$mode" = "-i" ]; then
                    rm -i "$file1"
               fi
        fi
    fi
}

compare_files() {
    directory="$1"
    modeForDeletion="$2"
    modeForCompare="$3"
    find "$directory" -type f -print0 | while IFS= read -r -d '' file1; do
        while IFS= read -r -d '' file2; do
            if [ "$file1" != "$file2" ]; then
                if [ "$modeForCompare" = "-c" ]; then
                    check_same_content $file1 $file2 $modeForDeletion
                fi
                if [ "$modeForCompare" = "-n" ]; then
                    check_same_name $file1 $file2 $modeForDeletion
                fi
            fi
        done < <(find "$directory" -type f -print0)
    done
}

print_help_info() {
    # to be added
    echo "Usage: ./main.sh Parameter1 Parameter2"
    echo "Parameter1 -f to delete file instantly"
    echo "Parameter1 -i to ask before deleting"
    echo "Parameter2 -n to delete file with same name"
    echo "Parameter2 -c to delete file with same content"
    exit 0
}

# main 
path_to_directory="/Users/jendras/Prywatne/Books/"
if [ -z "$1" ]; then
    echo "Error: One or more parameters are empty"
    print_help_info
    exit 1 
fi
if [ "$1" = "-h" ]; then
    print_help_info
fi
if [ "$1" = "-f" ]; then
    compare_files "$path_to_directory" "$1" "$2"
fi
if [ "$1" = "-i" ]; then
    compare_files "$path_to_directory" "$1" "$2"
fi