#!/bin/bash

# Configuration
SITE="My Site"
SRC="/var/www/html/" # path to source
DEST_BASE="/home/admin/website-rsync-backup/backups" # path to destination
LOG_FILE="/var/log/mysite-backup.log" # path to log directory
RETENTION_DAILY=90
RETENTION_WEEKLY=52
RETENTION_MONTHLY=24
EMAIL_SCRIPT="/path/to/website-rsync-backup/send_notification.sh" # path to notification script
EXCLUDE=("cache" "tmp" "*.log") # Add your own files or directories to exclude

# Notification settings
ENABLE_NOTIFICATIONS=false  # Set to true to send notifications
NOTIFY_ON_FAILURE=true
NOTIFY_ON_SUCCESS=true

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
    if [ "$ENABLE_NOTIFICATIONS" = true ]; then
        local is_failure="$1"
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

# Backup function
backup() {
    local DEST="$1/$DATE"
    local TYPE="$2"
    mkdir -p "$DEST"
    log "Starting $TYPE backup to $DEST"
    
    # Prepare exclude options
    local exclude_opts=""
    for item in "${EXCLUDE[@]}"; do
        exclude_opts+="--exclude=$item "
    done
    
    if rsync -avz --delete $exclude_opts "$SRC" "$DEST"; then
        log "$TYPE backup completed successfully"
    else
        log "ERROR: $TYPE backup failed"
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
check_disk_space 1048576

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

# Usage with cron:
# 0 2 * * * /home/dan/website-rsync-backup/backup_script.sh

# Directory structure:
# website-rsync-backup/
#   - backup_script.sh
#   - send_notification.sh
#   - backups/
#     - daily/
#     - weekly/
#     - monthly/

# Make script executable:
# chmod +x backup_script.sh
