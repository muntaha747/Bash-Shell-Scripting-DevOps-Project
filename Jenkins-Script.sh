#!/bin/bash
#Description: This Script takes the Jenkins Metadata Backup and compress the file by using tar -cvzf command and uploads automatically AWS s3 Bucket. The AWS Credentials are passed dynamically.

JENKINS_PATH="$1"                   
export AWS_ACCESS_KEY_ID="$2"
export AWS_SECRET_ACCESS_KEY="$3"
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

# --- FUNCTIONS ---

# Writes timestamped entries to the log file
log_messages() {
    echo "$(date +"%Y-%m-%d_%H-%M-%S") - ${1}" >> "${LOG_FILE}"
}

# Function to upload backup tar to S3 bucket
copy_to_s3() {
    aws s3 cp "${TAR_FILE}" "s3://${S3_BUCKET}/"
    if [[ $? -ne 0 ]]; then
        log_messages "ERROR: S3 upload failed"
        return 1
    fi
    log_messages "Uploaded ${TAR_FILE} to s3://${S3_BUCKET}/"
}

# Function to copy Jenkins job config files
jenkins_job() {
    if [[ ! -d "${JENKINS_PATH}/jobs" ]]; then
        echo "Error: ${JENKINS_PATH}/jobs does not exist."
        exit 1
    fi

    for i in "${JENKINS_PATH}/jobs"/*; do
        [[ -d "${i}" ]] || continue

        job_name=$(basename "$i")
        destination_folder="${STAGING_DIR}/jobs/${job_name}"
        mkdir -p "${destination_folder}"

        find "${i}" -maxdepth 1 \
             \( -name "config.xml" -o -name "nextBuildNumber" \) \
             -exec cp -R {} "${destination_folder}" \;
    done

    log_messages "Jobs copied from ${JENKINS_PATH}/jobs"
}

# Function to create the archive
make_archive() {
    tar -czf "${TAR_FILE}" "${STAGING_DIR}"
    log_messages "Created archive ${TAR_FILE}"
}

# --- MAIN ---

if [[ -z "${JENKINS_PATH}" ]]; then
    echo "The Path is empty. Unfortunately the script cannot be executed."
    log_messages "The script cannot be executed - empty JENKINS_PATH"
    exit 1
fi

rm -rf "${STAGING_DIR}" "${TAR_FILE}"

# Creating a for loop to create 5 subs folders.

for i in plugins jobs secrets logs workspace nodes
do
    mkdir -p "${STAGING_DIR}"/"${i}"
    log_messages "Back up of each folders are done"
done

cp "${JENKINS_PATH}/"*.xml "${STAGING_DIR}" 2>/dev/null || true

#Copying all the jenkins folder metadata files to the staging area
cp "${JENKINS_PATH}/plugins/"*.[hj]pi "${STAGING_DIR}/plugins/" 2>/dev/null || true

if [ -n "$(ls -A "${JENKINS_PATH}/users/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/users/"* "${STAGING_DIR}/users/" 2>/dev/null || true
fi

if [ -n "$(ls -A "${JENKINS_PATH}/secrets/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/secrets/"* "${STAGING_DIR}/secrets/" 2>/dev/null || true
fi

if [ -n "$(ls -A "${JENKINS_PATH}/logs/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/logs/"* "${STAGING_DIR}/logs/" 2>/dev/null || true
fi

if [ -n "$(ls -A "${JENKINS_PATH}/workspace/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/workspace/"* "${STAGING_DIR}/workspace/" 2>/dev/null || true
fi

if [ -n "$(ls -A "${JENKINS_PATH}/nodes/" 2>/dev/null)" ]; then
    cp -R "${JENKINS_PATH}/nodes/"* "${STAGING_DIR}/nodes/" 2>/dev/null || true
fi

if [ -n "$(ls -A "${JENKINS_PATH}/jobs/" 2>/dev/null)" ]; then
    jenkins_job
fi

make_archive
rm -rf "${STAGING_DIR}"
copy_to_s3
echo "Backing up the script is done and now sit back, relax and enjoy"