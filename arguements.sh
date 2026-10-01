#!/bin/bash
#Author: Muntaha

# echo "This is my shell script name: $0 "
# echo "This is the First arguement of my script: $1 "
# echo "This is the Second arguement of my script: $2 "
# echo "This is the Third arguement of my script: $3 "
# echo "This is the Fourth arguement of my script: $4 "
# echo "This is the Fifth arguement of my script: $5 "
# echo "This is the Sixth arguement of my script: $6 "

if [[ $# -eq 0 ]]; then
    echo "Please atleast pass one arguement"
else
    echo "Arguements passed is ${#}"
fi
