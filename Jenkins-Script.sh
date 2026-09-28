#!/usr/bin/env bash

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

# --- Common Variables ---
JENKINS_PATH="$1"                   # Folder where Jenkins lives (e.g., /var/lib/jenkins)
AWS_KEY="$2"                        # AWS Access Key ID
AWS_SECRET="$3"                     # AWS Secret Access Key
S3_BUCKET="jenkins-metadata-backup" # S3 destination bucket

# Temporary folders & file paths
WORK_DIR="/tmp/jenkins-backup"
DATE_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ZIP_FILE_NAME="jenkins-archive-${DATE_STAMP}.tar.gz"
ZIP_FILE_PATH="/tmp/${ZIP_NAME}"
LOG_FILE="/var/log/jenkins_backup.log"


# --- FUNCTIONS ---

# Writes timestamped entries to the log file
log_message() {
    echo "$(date +"%A, %d %B %Y %I:%M %p") - $1" >> "${LOG_FILE}"
}

# Copies job configuration files into the temporary backup folder
backup_jobs() {

}
