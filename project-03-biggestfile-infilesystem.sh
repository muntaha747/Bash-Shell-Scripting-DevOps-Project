#!/bin/bash
set -euo pipefail
echo "This program get the first 10 biggest file in the file system passed via positional arguements"
path="$1"
echo ${path}
du -ah $path | sort -hr | head -n 5 > /tmp/filesize.txt
echo "This is the list of the big files in the file system ${path}"
cat /tmp/filesize.txt