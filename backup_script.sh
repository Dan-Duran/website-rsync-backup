#!/bin/bash

# Directories (to be set)
SRC="/var/www/mysite/html/"
DEST_BASE="/home/admin/mysite-backups"
DATE=$(date +%Y-%m-%d)

# Backup function
backup() {
    local DEST="$1/$DATE"
    mkdir -p $DEST
    rsync -av --delete $SRC $DEST
}

# Rotate function
rotate() {
    local DEST="$1"
    local LIMIT="$2"
    cd $DEST
    ls -t | tail -n +$((LIMIT + 1)) | xargs rm -rf
}

# Perform daily backup
backup "$DEST_BASE/daily"
rotate "$DEST_BASE/daily" 90 # set rotation days here

# Perform weekly backup (only on Sundays)
if [ $(date +%u) -eq 7 ]; then
    backup "$DEST_BASE/weekly"
    rotate "$DEST_BASE/weekly" 52 # set rotation weeks here
fi

# Perform monthly backup (only on the 1st of the month)
if [ $(date +%d) -eq 01 ]; then
    backup "$DEST_BASE/monthly"
    rotate "$DEST_BASE/monthly" 24 # set rotation months here
fi

# to be used with cron: 
# 0 2 * * * /home/admin/mysite-backups/backup_script.sh

# directories:
# mysite-backups
#   - backup_script.sh
#   - daily
#   - monthly
#   - weekly

# make scriopt executable 
# chmod +x backup_script.sh
