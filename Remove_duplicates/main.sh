#!/bin/bash

# Defined directories to look for duplicates
directories=(
    "test"
    "test2"
)

printFileInfo() {
    local file="$1"
    echo "File name: $file"
    echo "Owner: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 3)"
    echo "Permissions: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 1)"
    echo "Last Modified: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 6-8)"
}

printHelpInfo() {
    echo "This script can be used to delete duplicates of files by content or by name"
    echo "Usage: ./main.sh [-f|i|n|c]"
    echo "Default: -i -c"
    echo "The following options are available:"
    echo "f	Delete file instantly."
    echo "i	Ask before deleting."
    echo "n	Delete file with same name."
    echo "c	Delete file with same content."
    exit 0
}

# Functions to delete files
deleteFile() {
    local file="$1"
    rm "$file"
    echo "File '$file' deleted."
}

promptDeleteFile() {
    local file="$1"
    echo -n "Do you want to delete '$file'? (y/n): "
    read -r answer < /dev/tty
    if [ "$answer" = "y" ]; then
        deleteFile "$file"
        exit 0
    elif [ "$answer" = "n" ]; then
        echo "File '$file' not deleted."
        exit 0
    fi
}

# Functions to manage files with same name
handleDuplicateName() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    printFileInfo "$file1"
    echo " "
    printFileInfo "$file2"
    if [ "$mode" = "-f" ]; then
        deleteFile "$file1"
    elif [ "$mode" = "-i" ]; then
        promptDeleteFile "$file1"
    fi
}

checkSameName() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$(basename "$file1")" = "$(basename "$file2")" ]; then
        handleDuplicateName "$file1" "$file2" "$mode"
    fi
}

# Functions to menage files with same content
handleDuplicateContent() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    printFileInfo "$file1"
    echo " "
    printFileInfo "$file2"
    if [ "$mode" = "-f" ]; then
        deleteFile "$file1"
    elif [ "$mode" = "-i" ]; then
        promptDeleteFile "$file1"
    fi
}

checkSameContent() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    # Used cmp to compare byte by byte so it works with img and music files
    if [ "$file1" != "$file2" ]; then
        if cmp -s "$file1" "$file2"; then
            handleDuplicateContent "$file1" "$file2" "$mode"
        fi
    fi
}

# Functions to process directories
performGivenComparsionType() {
    local file1="$1"
    local file2="$2"
    local modeForCompare="$3"
    local modeForDeletion="$4"

    if [ "$modeForCompare" = "-c" ]; then
        checkSameContent "$file1" "$file2" "$modeForDeletion"
    elif [ "$modeForCompare" = "-n" ]; then
        checkSameName "$file1" "$file2" "$modeForDeletion"
    fi
}

processAndCompareFiles() {
    local dir1="$1"
    local dir2="$2"
    local modeForCompare="$3"
    local modeForDeletion="$4"
    find "$dir1" -type f -print0 | while IFS= read -r -d '' file1; do
        find "$dir2" -type f -print0 | while IFS= read -r -d '' file2; do
            if [ "$file1" != "$file2" ]; then
                performGivenComparsionType "$file1" "$file2" "$modeForCompare" "$modeForDeletion"
            fi
        done
    done
}

compareFiles() {
    local modeForDeletion="$1"
    local modeForCompare="$2"

    if [ "${#directories[@]}" -eq 1 ]; then
        processAndCompareFiles "${directories[0]}" "${directories[0]}" "$modeForCompare" "$modeForDeletion"
    else
        for ((i=0; i < ${#directories[@]}; i++)); do
            for ((j=$i+1; j < ${#directories[@]}; j++)); do
                processAndCompareFiles "${directories[$i]}" "${directories[$j]}" "$modeForCompare" "$modeForDeletion"
            done
        done
    fi
}

# Predefined default parameters
deleteType="-i"
compareType="-c"

if [ $# -gt 2 ]; then
    echo "Too many parameters provided."
    echo " "
    printHelpInfo
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|-i)
            deleteType="$1"
            shift
            ;;
        -n|-c)
            compareType="$1"
            shift
            ;;
        -h)
            printHelpInfo
            ;;
        *)
            echo "Invalid parameter: $1"
            printHelpInfo
            exit 1
            ;;
    esac
done

compareFiles "$deleteType" "$compareType"