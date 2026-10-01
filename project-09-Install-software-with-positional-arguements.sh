#!/bin/bash
#Author: Muntaha Bhaiji
#Description: Multiple Packages.

# set euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: Please Provide the software name as a command line arguement"
    exit 1
    if [[ `id-u` -ne 0 ]]; then
    echo "Please run as a root user"
    exit 2
    fi
fi



for softwares in $@
do
    if which $softwares &> /dev/null; then
        echo "Already ${softwares} is installed on the VM"
    else
        echo "Installing the $softwares softwares"
        yum install $softwares -y &> /dev/null
        if $? -eq 0; then
            echo "All the $softwares softwares are installed successfully"
        else
            echo "Unable to install $softwares softwares"
        fi
    fi
done

