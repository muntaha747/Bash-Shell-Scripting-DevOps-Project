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
    aws s3 cp "${TAR_FILE}" "S3://${s3_BUCKET}/"
}

#Function to create backup Jenkins jobs
jenkins_job() {
    if [[ ! -d "${JENKINS_PATH}/jobs"]]; then
            echo "This is not a directory"
            exit 1
    fi

    for i in "${JENKINS_PATH}/jobs"/*;
    do
        [[ -d "${i}" ]] || continue
        job_name=$(basename "$i")
        destination_folder="${STAGING_DIR}/jobs/${job_name}"
        mkdir -p "${dest}"
        find "${i}" -maxdepth 1 \( -name "config.xml" -o -name "nextBuilderNumber" -o -name builds/ \) -exec cp -R {} "${destination_folder}" \;
    done
    
    log_message "Jobs are copied from the "${JENKINS_PATH}/jobs" and pasted in the ${destination_folder}"
}

#Function to convert all the files into one folder and tar it.

zip() {
    tar -cvzf "${TAR_FILE}" "${STAGING_DIR}"
}

# Main and calling the functions.
if [[ -z "${JENKINS_PATH}"]]; then
    echo "The Path is empty and the folder is empty. Unfortunately the script cannot be executed"
    exit 1
    log messages "The script cannot be executed"
fi


