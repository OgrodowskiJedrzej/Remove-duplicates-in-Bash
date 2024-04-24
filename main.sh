#!/bin/bash

directories=(
    "/Users/jendras/Downloads/TEST1/"
    "/Users/jendras/Downloads/TEST2/"
)

printFileInfo() {
    local file="$1"
    echo "File name: $file"
    echo "Owner: $(ls -ld "$file" | tr -s " " | cut -d ' ' -f 3)"
    echo "Permissions: $(ls -ld "$file" | cut -c 2-10)"
    echo "Last Modified: $(ls -l "$file" | tr -s " " | cut -d ' ' -f 6-8)"
    echo " "
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
            while true; do
                echo -n "Do you want to delete '$file1'? (y/n): "
                read -r answer < /dev/tty # had to do this because terminal on mac didnt wait for answer 
                if [ "$answer" = "y" ]; then
                    rm -f "$file1"
                    break
                elif [ "$answer" = "n" ]; then
                    exit
                fi
            done
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
                    while true; do
                        echo -n "Do you want to delete '$file1'? (y/n): "
                        read -r answer < /dev/tty # had to do this because terminal on mac didnt wait for answer 
                    if [ "$answer" = "y" ]; then
                        rm -f "$file1"
                        break
                    elif [ "$answer" = "n" ]; then
                        exit
                    fi
                done
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

if [ -n "$1" ]; then
    deleteType="$1"
else
    deleteType="$defaultDeleteType"
fi
if [ -n "$2" ]; then
    compareType="$2"
else
    compareType="$defaultCompareType"
fi

if [ "$1" = "-h" ]; then
    printHelpInfo
elif [ "$1" = "-f" ] || [ "$1" = "-i" ]; then
    if [ -n "$2" ]; then
        compareFiles "$deleteType" "$compareType"
    else
        echo "Missing second argument."
        echo " "
        printHelpInfo
    fi
else
    compareFiles "$deleteType" "$compareType"
fi