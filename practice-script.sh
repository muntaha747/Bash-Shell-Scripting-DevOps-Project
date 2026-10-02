#!/bin/bash

folder="${HOME}/Bash-Shell_Scripting-DevOps-Project"

#!/bin/bash
set -euo pipefail

folder="${HOME}/Bash-Shell_Scripting-DevOps-Project"

if [[ -d "$folder" ]] && [[ -n "$(ls -A "$folder")" ]]; then
    echo "You need to provide the positional arguments"

    for files in "$folder"/*
    do
        echo "${files}"
        echo "These are the files"
    done
else
    echo "Directory is missing or empty: $folder"
fi#!/bin/bash
set -euo pipefail

folder="${HOME}/Bash-Shell_Scripting-DevOps-Project"

if [[ -d "$folder" ]] && [[ -n "$(ls -A "$folder")" ]]; then
    echo "You need to provide the positional arguments"

    for files in "$folder"/*
    do
        echo "${files}"
        echo "These are the files"
    done
else
    echo "Directory is missing or empty: $folder"
fi