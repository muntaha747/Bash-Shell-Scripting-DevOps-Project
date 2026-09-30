#!/bin/bash
set -euo pipefail

TAR_FILE="/home/ubuntu/prometheus-3.15.0.linux-amd64.tar.gz"
EXTRACTED_FILE="/home/ubuntu/prometheus-3.15.0.linux-amd64"
URL="https://github.com/prometheus/prometheus/releases/download/v3.15.0/prometheus-3.15.0.linux-amd64.tar.gz"

echo "Downloading the Prometheus Binaries"

if [[ -d "${EXTRACTED_FILE}" ]]; then
    echo "The extracted file is already existed in our system and it will not be extracted and downloaded"

elif [[ -f "${TAR_FILE}" ]]; then
    echo "The file is already exist in your system so no need to download it again."
    tar -zxvf "${TAR_FILE}" -C "${HOME}"

else
    echo "The executable binary does not exists"
    wget -O "${TAR_FILE}" "${URL}"
    tar -zxvf "${TAR_FILE}" -C "${HOME}"
    echo "Prometheus file has been extracted now you can start your prometheus"
fi

echo "The Bash Script ran and fully executed 😍"