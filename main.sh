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

print_file_info "/Users/jendras/Prywatne/Books/test.txt"