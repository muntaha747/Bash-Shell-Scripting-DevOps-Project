#!/bin/bash
#Description: Differrent types of OS System are installed by using Bash Shell scripting.

echo "Shell script to install git on the OS"
echo "Installation Started"

if [[ "$(uname)" == "Linux" ]]; then
    echo "This is the Linux Box, installing the git"
    if [[ -n "$(command -v apt)" ]]; then
        echo "This is debian based Linux"
        sudo apt install git -y
    elif [[ -n "$(command -v dnf)" ]]; then
        echo "This is RPM based Linux"
        sudo dnf install git -y
    fi

elif [[ "$(uname)" == "Darwin" ]]; then
    echo " This is MacOS"
    brew install git
else
    echo "not installing the git software"
fi