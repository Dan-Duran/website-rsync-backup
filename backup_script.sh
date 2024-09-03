#!/bin/bash

# Load general settings from settings.sh file
SETTINGS_FILE="./settings.sh"
if [ -f "$SETTINGS_FILE" ]; then
    source "$SETTINGS_FILE"
else
    echo "settings.sh file not found in the current directory. Please ensure settings.sh is in the same directory as this script."
    exit 1
fi

# Now that we have BASE_DIR, we can use it to locate the .env file
ENV_FILE="$BASE_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo ".env file not found at $ENV_FILE. Please create a .env file with the necessary sensitive information."
    exit 1
fi

# Validate that all required variables are set
required_vars=(
    "BASE_DIR" "REMOTE_IP" "REMOTE_PORT" "REMOTE_USER" "SSH_KEY" "REMOTE_PATH"
    "SITE" "DEST_BASE" "RETENTION_DAILY" "RETENTION_WEEKLY" "RETENTION_MONTHLY"
    "REQUIRED_DISK_SPACE" "EXCLUDE"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required variable $var is not set. Please check your .env and settings.sh files."
        exit 1
    fi
done

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send email notification
send_notification() {
    local is_failure="$1"
    if [ "$ENABLE_NOTIFICATIONS" = true ]; then
        if ([ "$is_failure" = true ] && [ "$NOTIFY_ON_FAILURE" = true ]) || \
           ([ "$is_failure" = false ] && [ "$NOTIFY_ON_SUCCESS" = true ]); then
            if [ -x "$EMAIL_SCRIPT" ]; then
                "$EMAIL_SCRIPT" "$is_failure" "$SITE"
            else
                log "WARNING: Email script not found or not executable"
            fi
        fi
    else
        log "Notifications are disabled. Skipping email notification."
    fi
}

# Function to check available disk space
check_disk_space() {
    local required_space=$1
    mkdir -p "$DEST_BASE"  # Ensure the destination directory exists
    local available_space=$(df -k "$DEST_BASE" | awk 'NR==2 {print $4}')
    if [ -z "$available_space" ]; then
        log "ERROR: Unable to determine available disk space"
        send_notification true
        exit 1
    fi
    if [ "$available_space" -lt "$required_space" ]; then
        log "ERROR: Not enough disk space. Required: ${required_space}KB, Available: ${available_space}KB"
        send_notification true
        exit 1
    fi
}

# Function to prepare and diagnose the rsync command
prepare_rsync_command() {
    log "Preparing rsync command..."

    # Prepare exclude options
    local exclude_opts=""
    for item in "${EXCLUDE[@]}"; do
        exclude_opts+="--exclude=$item "
    done

    if [ "$BACKUP_FROM_REMOTE_SITE" = true ]; then
        if [ "$SSH_METHOD" = "key" ]; then
            RSYNC_CMD="rsync -avz $exclude_opts --delete -e \"ssh -i $SSH_KEY -p $REMOTE_PORT\" $REMOTE_USER@$REMOTE_IP:$REMOTE_PATH $DEST"
        else
            RSYNC_CMD="sshpass -p \"$REMOTE_PASSWORD\" rsync -avz $exclude_opts --delete -e \"ssh -o StrictHostKeyChecking=no -p $REMOTE_PORT\" $REMOTE_USER@$REMOTE_IP:$REMOTE_PATH $DEST"
        fi

        # Test SSH connection
        log "Testing SSH connection to $REMOTE_USER@$REMOTE_IP..."
        if ! ssh -i "$SSH_KEY" -p "$REMOTE_PORT" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_IP" "echo SSH connection successful"; then
            log "ERROR: SSH connection test failed. Please check the SSH credentials and connection."
            send_notification true
            exit 1
        else
            log "SSH connection successful."
        fi

        # Test remote directory access
        log "Testing access to remote directory $REMOTE_PATH..."
        if ! ssh -i "$SSH_KEY" -p "$REMOTE_PORT" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_IP" "ls $REMOTE_PATH" > /dev/null 2>&1; then
            log "ERROR: Cannot access remote directory $REMOTE_PATH. Check if the directory exists and permissions are correct."
            send_notification true
            exit 1
        else
            log "Access to remote directory $REMOTE_PATH confirmed."
        fi

    else
        RSYNC_CMD="rsync -avz $exclude_opts --delete $SRC $DEST"
    fi

    log "Rsync command prepared: $RSYNC_CMD"
}

# Backup function
backup() {
    local DEST="$1/$DATE"
    local TYPE="$2"
    mkdir -p "$DEST"
    log "Starting $TYPE backup to $DEST"

    prepare_rsync_command  # Construct the rsync command

    log "Running command: $RSYNC_CMD"
    
    if eval $RSYNC_CMD > /tmp/rsync_output.log 2>&1; then
        log "$TYPE backup completed successfully"
    else
        log "ERROR: $TYPE backup failed"
        log "Rsync output:"
        cat /tmp/rsync_output.log >> "$LOG_FILE"

        # Check for common issues in the output and provide a detailed message
        if grep -q "Permission denied" /tmp/rsync_output.log; then
            log "ERROR: Permission denied. The user '$REMOTE_USER' may not have access to '$REMOTE_PATH' on the remote server."
        elif grep -q "No such file or directory" /tmp/rsync_output.log; then
            log "ERROR: The specified directory '$REMOTE_PATH' does not exist on the remote server."
        else
            log "ERROR: Rsync failed due to an unspecified issue. Please check the full log for more details."
        fi

        send_notification true
        exit 1
    fi
}

# Rotate function
rotate() {
    local DEST="$1"
    local LIMIT="$2"
    local TYPE="$3"
    log "Rotating $TYPE backups in $DEST"
    cd "$DEST" || exit 1
    if ls -t | tail -n +$((LIMIT + 1)) | xargs rm -rf; then
        log "$TYPE backup rotation completed"
    else
        log "WARNING: $TYPE backup rotation failed"
        send_notification true
    fi
}

# Main execution
DATE=$(date +%Y-%m-%d)
log "Starting backup process for $SITE"

# Check disk space (assuming 1GB required, adjust as needed)
check_disk_space "$REQUIRED_DISK_SPACE"

# Perform daily backup
backup "$DEST_BASE/daily" "Daily"
rotate "$DEST_BASE/daily" "$RETENTION_DAILY" "Daily"

# Perform weekly backup (only on Sundays)
if [ "$(date +%u)" -eq 7 ]; then
    backup "$DEST_BASE/weekly" "Weekly"
    rotate "$DEST_BASE/weekly" "$RETENTION_WEEKLY" "Weekly"
fi

# Perform monthly backup (only on the 1st of the month)
if [ "$(date +%d)" -eq 01 ]; then
    backup "$DEST_BASE/monthly" "Monthly"
    rotate "$DEST_BASE/monthly" "$RETENTION_MONTHLY" "Monthly"
fi

log "Backup process completed for $SITE"
send_notification false
