#!/bin/bash

echo "============= In this script we will be checking if the docker services are active or not================"
echo "This shell script can smoothly run on any Linux Distros"

STATUS=$(systemctl status docker | awk 'NR==3 {print $2}' | cut -d ":" -f 2 | grep active)
echo "$STATUS"
if [[ ${STATUS} == "active" ]]; then
    echo "The Docker Enginer is running"
else
    echo "The containerd is stopped in your machine"
    systemctl start docker
fi
echo "$(systemctl status docker)" 
echo "EOS"

