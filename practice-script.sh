#!/bin/bash
set -euo pipefail

folder="${HOME}/Desktop/Linux-Bash-Scripting-Master/Bash-Shell-Scripting-DevOps-Project"


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