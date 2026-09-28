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
    if [[ ! -d "${JENKINS_PATH}" ]]; then
        echo " This is not the directory and the script will not be executed"
    fi

    for i in "${JENKINS_PATH}/jobs"/*;
    do
        if [[ -d "${i}" ]]; then
            cd "${JENKINS_PATH}"
            job_name=$(basename "${i}")
            placement_dir="${WORK_DIR}"/jobs/"${job_name}" # This is the directory which we created to store the backup
            mkdir -p "${placement_dir}" # This is the directory which we created to store the backup from the command below.
            find ${i} -maxdepth 1 \( -name "builds" || -name "*.xml" || -name "nextBuilderNumber" \) -exec cp -R {} "${placement_dir}" \;

        fi
    done

log_message " This portion is executed"
}

# Function to upload backup in the AWS s3 Bucket
copyto_s3() {
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp ${ZIP_FILE_NAME}} s3://wezvatech-jenkins-backup-9739110917/
    exitcode=$?
    if [ "$exitcode" != "1" ] && [ "$exitcode" != "0" ]; then
      exit $exitcode
    fi
    log_message "Copied Jenkins backup tar to S3 bucket .."
}



