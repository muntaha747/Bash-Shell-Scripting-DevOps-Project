#!/bin/bash

# --- Common Variables ---
JENKINS_PATH="$1"                   # Folder where Jenkins lives (e.g., /var/lib/jenkins)
AWS_ACCESS_KEY_ID="$2"                       
AWS_SECRET_ACCESS_KEY="$3"                     
S3_BUCKET="jenkins-metadata-backup"
STAGING_DIR="/tmp/jenkins-backup"
LOG_FILE="/var/log/jenkins_backup.log"
DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TAR_FILE="/tmp/jenkins-backup-${DATE_STAMP}.tar.gz"



# 1. Ensure the script is run as root
if [[ $UID != 0 ]]; then
    echo "Error: Please run this script as root."
    exit 1
fi


# 2. Check that all required inputs are provided when running the script
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "Usage: $0 <JENKINS_PATH> <AWS_KEY> <AWS_SECRET>"
    exit 1
fi

# Creating Functions to be executed.
# Writes log message timestamped entries to the log file.
log_messages() {
    echo "$(date +"%Y-%m-%d_%H-%M-%S") - ${1}" >> "${LOG_FILE}"
}
#Function to create an aws s3 bucket.
copy_to_s3() {
    AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    aws s3 cp "${TAR_FILE}" "S3://${S3_BUCKET}/"

}



