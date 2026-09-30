#!/bin/bash
# set -euo pipefail

# for i in 1 2 3 4 5 6;
# do
#     echo $i
# done

PROJECT="${HOME}/DevOps-Tasks/Bash-Shell-Scripting-DevOps-Project"
for folder in $(find ${PROJECT} -type d); do
    echo "the folder in ${folder}"
    if [[ -d test ]]; then
        echo "This folder exists"
        echo "Removing the folder"
        rm -rf test
    else
        echo "Test folder does not exists"
    fi
done