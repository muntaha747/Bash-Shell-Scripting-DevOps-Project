#!/bin/bash
echo "This script delete the files which are older than 30 days"
path="$1"
echo "${path}"
find ${path} -mtime +30 -delete
echo "Files are successfully deleted"
