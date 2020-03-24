#!/bin/bash

print_usage () {
	echo -e "Usage:\n"
	echo -e "${0} <folder with CFG files to process> <version to update files to> \n\n"
}

# Main
if [[ "$#" -ne 2]]; then
	print_usage
	exit 0
else
    for file in "${1}"/*
    do
        echo "Processing ${file}..."
        sed -i.orig  "s/.*CfgVersion\=.*/CfgVersion=${2}/" ${file}
        rm ${file}.orig
    done
fi