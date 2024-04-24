#!/bin/bash

directories=(
    "/Users/jendras/Downloads/TEST1/"
    "/Users/jendras/Downloads/TEST2/"
)

printFileInfo() {
    local file="$1"
    if [ -e "$file" ]; then
        echo "File name: $file"
        echo "Owner: $(ls -ld "$file" | tr -s " " | cut -d ' ' -f 3)"
        echo "Permissions: $(ls -ld "$file" | cut -c 2-10)"
        echo "Last Modified: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 6-8)"
        echo " "
    else
        echo "File not found: $file"
    fi
}

checkSameName() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$("$file1")" = "$("$file2")" ]; then
        printFileInfo $file1
        echo " "
        printFileInfo $file2
        if [ "$mode" = "-f" ]; then
            rm -f "$file1"
            echo " "
        fi
        if [ "$mode" = "-i" ]; then
            rm -i "$file1"
            echo " "
        fi
    fi 
}

checkSameContent() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$file1" != "$file2" ]; then
        if cmp -s "$file1" "$file2"; then
            printFileInfo $file1
            echo " "
            printFileInfo $file2
               if [ "$mode" = "-f" ]; then
                    rm -f "$file1"
                    echo " "
               fi
               if [ "$mode" = "-i" ]; then
                    rm -i "$file1"
                    echo " "
               fi
        fi
    fi
}

compareFiles() {
    local modeForDeletion="$1"
    local modeForCompare="$2"

    for directory in "${directories[@]}"; do
        find "$directory" -type f -print0 | while IFS= read -r -d '' file1; do
            for compare_directory in "${directories[@]}"; do
                if [ "$directory" != "$compare_directory" ]; then
                    find "$compare_directory" -type f -print0 | while IFS= read -r -d '' file2; do
                        if [ "$file1" != "$file2" ]; then
                            if [ "$modeForCompare" = "-c" ]; then
                                checkSameContent "$file1" "$file2" "$modeForDeletion"
                            fi
                            if [ "$modeForCompare" = "-n" ]; then
                                checkSameName "$file1" "$file2" "$modeForDeletion"
                            fi
                        fi
                    done
                fi
            done
        done
    done
}

printHelpInfo() {
    echo "This script can be used to delete duplicates of files by content or by name"
    echo "Usage: ./main.sh [Parameter1] [Parameter2]"
    echo "Default: Parameter1 -i Parameter2 -c"
    echo "The following options are available:"
    echo "Parameter1: -f to delete file instantly"
    echo "Parameter1: -i to ask before deleting"
    echo "Parameter2: -n to delete file with same name"
    echo "Parameter2: -c to delete file with same content"
    exit 0
}

defaultDeleteType="-i"
defaultCompareType="-c" 

if [ -z "$1" ]; then
    compareFiles "$defaultDeleteType" "$defaultCompareType"
fi
if [ "$1" = "-h" ]; then
    printHelpInfo
fi
if [ "$1" = "-f" ]; then
    compareFiles "$1" "$2"
fi
if [ "$1" = "-i" ]; then
    compareFiles "$1" "$2"
fi