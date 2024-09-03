#!/bin/bash

# Configuration
SRC="/var/www/mysite/html/"
DEST_BASE="/home/admin/mysite-backups"
LOG_FILE="/var/log/mysite-backup.log"
RETENTION_DAILY=90
RETENTION_WEEKLY=52
RETENTION_MONTHLY=24

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check available disk space
check_disk_space() {
    local required_space=$1
    local available_space=$(df -k "$DEST_BASE" | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$required_space" ]; then
        log "ERROR: Not enough disk space. Required: ${required_space}KB, Available: ${available_space}KB"
        exit 1
    fi
}

# Backup function
backup() {
    local DEST="$1/$DATE"
    local TYPE="$2"
    mkdir -p "$DEST"
    log "Starting $TYPE backup to $DEST"
    if rsync -avz --delete "$SRC" "$DEST"; then
        log "$TYPE backup completed successfully"
    else
        log "ERROR: $TYPE backup failed"
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
    fi
}

# Main execution
DATE=$(date +%Y-%m-%d)
log "Starting backup process"

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

log "Backup process completed"

# Usage with cron:
# 0 2 * * * /home/admin/mysite-backups/backup_script.sh

# Directory structure:
# mysite-backups/
#   - backup_script.sh
#   - daily/
#   - weekly/
#   - monthly/

# Make script executable:
# chmod +x backup_script.sh
