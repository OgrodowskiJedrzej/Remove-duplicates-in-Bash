#!/bin/bash

# list of directories to search for duplicates in, you can add them manually here by providing path to directory
directories=(
    "TESTDIRECTORY1/"
    "TESTDIRECTORY2/"
)

printFileInfo() {
    local file="$1"
    echo "File name: $file"
    echo "Owner: $(ls -ld "$file" | tr -s " " | cut -d ' ' -f 3)"
    echo "Permissions: $(ls -ld "$file" | cut -c 2-10)"
    echo "Last Modified: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 6-8)"
    echo " "
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

checkSameName() {
    local file1="$1"
    local file2="$2"
    local mode="$3"
    if [ "$(basename "$file1")" = "$(basename "$file2")" ]; then
        printFileInfo $file1
        echo " "
        printFileInfo $file2
        if [ "$mode" = "-f" ]; then
            rm -f "$file1"
            echo " "
        fi
        if [ "$mode" = "-i" ]; then
                echo -n "Do you want to delete '$file1'? (y/n): "
                read -r answer < /dev/tty # necessary because terminal on mac didnt wait for answer 
            if [ "$answer" = "y" ]; then
                rm -f "$file1"
                exit 0
            elif [ "$answer" = "n" ]; then
                exit 0
            fi
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
                        echo -n "Do you want to delete '$file1'? (y/n): "
                        read -r answer < /dev/tty # had to do this because terminal on mac didnt wait for answer 
                    if [ "$answer" = "y" ]; then
                        rm -f "$file1"
                        exit 0
                    elif [ "$answer" = "n" ]; then
                        exit 0
                    fi
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

# predefined default parameters
deleteType="-i"
compareType="-c"

# handling parameters in any order where "$#" is number of parameters and "-gt" is comparing to given value after (>)
if [ "$#" -gt 2 ]; then
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
            exit 1
            ;;
    esac
done

compareFiles "$deleteType" "$compareType"
