#!/bin/bash
#Description: Disk Utilization Shell Script.
set -euo pipefail

echo "This script check the disk usage in the Linux system"
disk_usage=$(df -h | grep /dev/nvme0n1p13 | awk '{print $5}' | cut -d '%' -f1)
echo "${disk_usage} of the disk is filled"

if [[ "${disk_usage}" -gt 80 ]]; then
    echo "Disk is utilized more than 80%, expand the exsisting disk or delete some files"

else
    echo "Enough disk space is available"
fi
