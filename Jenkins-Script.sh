# Ensure that running this script as a Super User or Sudo User or Root User.
if [[ $UID != 0 ]]; then
    echo "Please run this script as a root user"
    exit 1
fi

# Jenkins Define Variables
JENKINS_HOME=$1
AWS_ACCESS_KEY_ID=$2
AWS_SECRET_ACCESS_KEY=$3
DEST_FILE="/tmp/test"
TEMP_DIR="/tmp"
ARCHIVE_NAME="jenkins-backup"
ARCHIVE_DIR="${TEMP_DIR}/${ARCHIVE_NAME}"
TEMP_TAR_FILE_NAME="{TEMP_DIR}/jenkins-archive.tar.gz"
FINAL_TAR_FILE_NAME=jenkins-archive-$(date +"%A, %d %B %Y %I:%M %p").tar.gz
LOG_FILE="/var/log/jenkins_backup.log"