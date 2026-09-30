#!/bin/bash
echo "Downloading the Prometheus Binaries"
if [[ -e /home/ubuntu/prometheus-3.15.0.linux-amd64.tar.gz ]]; then
    echo "The file is already exsist in your system so no need to download it again."
    tar -zxvf /home/ubuntu/prometheus-3.15.0.linux-amd64.tar.gz

else
    echo "The executeable binary does not exsists"
    wget https://github.com/prometheus/prometheus/releases/download/v3.15.0/prometheus-3.15.0.linux-amd64.tar.gz
    tar -zxvf /home/ubuntu/prometheus-3.15.0.linux-amd64.tar.gz
    echo "Prometheus file has been extracted now you can start your proemetheus"
fi
