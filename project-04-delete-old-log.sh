#!/bin/bash
set -euo pipefail
echo "This script delete the files which are older than 30 days"
path="$1"
echo "${path}"
find ${path} -mtime +30 -delete

if [[ $? -eq 0 ]]; then
    echo "Files are successfully deleted"
else
    echo "Deletion was having some issue"
fi