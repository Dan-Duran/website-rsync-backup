# The base directory will be where you clone this git plus the directory /website-rsync-backup
BASE_DIR="/home/admin/website-rsync-backup"

# General Configuration
SITE="My Website" #for sending notifications
DEST_BASE="$BASE_DIR/backups" # by default inside /website-rsync-backup/backups
RETENTION_DAILY=90
RETENTION_WEEKLY=52
RETENTION_MONTHLY=24
REQUIRED_DISK_SPACE=1048576 # Required disk space in KB (default: 1GB)
LOG_FILE="$BASE_DIR/mysite-backup.log" # by default in /website-rsync-backup/mysite-backup.log


# Include Patterns (for specific files or directories to include from anywhere)
INCLUDE=(
    "/var/lib/mysql/dumps/domain.sql"
    "/home/user/somefile.txt"
)

# Exclude Patterns
EXCLUDE=(
    "cache"
    "**.log"
    "mycustom/exclude"
    "tmp"
    "**.tmp"
    "specific-file.txt"
    "node_modules"
    # you can add any other patterns, paths and files
)

# Backup Configuration
BACKUP_FROM_REMOTE_SITE=true #if true you need to add the key info in the .env file
SRC="/home/dan/test/"  # FOR LOCAL if BACKUP_FROM_REMOTE_SITE is set to false
REMOTE_PATH="/var/www/html/"  # FOR REMOTE if BACKUP_FROM_REMOTE_SITE is set to true
REMOTE_PORT=22
SSH_METHOD="key" # do not add password when generating key

# Notification Settings
ENABLE_NOTIFICATIONS=true # this will disable executing send_notification.sh as well as the below
NOTIFY_ON_FAILURE=true
NOTIFY_ON_SUCCESS=true
EMAIL_SCRIPT="$BASE_DIR/send_notification.sh"

# Email Method
EMAIL_METHOD="postmark" # Set to "smtp" or "postmark"

# SMTP Configuration (non-sensitive parts of smtp)
SMTP_SERVER="smtp.example.com"
SMTP_PORT=587

# Postmark Configuration (non-sensitive parts of postmark)
POSTMARK_API_URL="https://api.postmarkapp.com/email"
