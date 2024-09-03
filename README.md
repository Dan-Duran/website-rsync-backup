# Website Rsync Backup Automation Script

This repository contains a powerful and feature-rich Bash script for automating website backups using rsync. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently. It includes configurable email notifications for backup successes and failures, and offers advanced options for remote backups, logging, and error handling.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Settings File](#settings-file)
  - [Environment File](#environment-file)
  - [Configuring Exclusions](#configuring-exclusions)
- [Usage](#usage)
- [Logging](#logging)
- [Email Notifications](#email-notifications)
- [Directory Structure](#directory-structure)
- [Error Handling](#error-handling)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Features

- **Daily, Weekly, and Monthly Backups**: Custom retention periods for each (default: 90 days, 52 weeks, 24 months).
- **Automatic Rotation**: Automatically removes old backups to manage storage efficiently.
- **Rsync-Based**: Utilizes rsync for efficient, incremental backups, minimizing bandwidth and storage usage.
- **Customizable Exclusions**: Easily exclude specific files or directories from backups.
- **Comprehensive Error Handling and Logging**: Logs detailed information and handles errors gracefully.
- **Disk Space Check**: Ensures sufficient disk space is available before starting backups (default 1GB).
- **Root Privilege Check**: Ensures the script is run with the necessary permissions.
- **Configurable Email Notifications**: Supports notifications via SMTP or Postmark, with options to enable/disable based on success or failure.
- **Remote Backup Capability**: Option to back up from a remote source over SSH using key-based authentication.
- **Centralized Configuration**: Configurations are managed via `settings.sh` file and `.env` for sensitive info, making it easy to manage and update settings.

## Prerequisites

- Bash shell (version 4.0 or later)
- rsync (version 3.1.0 or later)
- cron (for scheduling)
- Root access (sudo)
- mutt (only if using SMTP for email notifications)
- curl (for Postmark API calls)

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/Dan-Duran/website-rsync-backup.git
   ```
2. Navigate to the cloned directory:
   ```
   cd website-rsync-backup
   ```
3. Make the scripts executable:
   ```
   chmod +x backup_script.sh send_notification.sh
   ```
4. Install mutt for notifications (ONLY if using SMTP):
   ```
   sudo apt-get install mutt
   ```

## Configuration

### Settings File

Create a `settings.sh` file in the same directory as your scripts. This file will contain non-sensitive configurations. Here's an example:

```bash
# Base Directory Configuration
BASE_DIR="/path/to/website-rsync-backup"

# General Configuration
SITE="YourSiteName"
DEST_BASE="$BASE_DIR/backups"
RETENTION_DAILY=90
RETENTION_WEEKLY=52
RETENTION_MONTHLY=24
REQUIRED_DISK_SPACE=1048576 # Required disk space in KB (default: 1GB)
LOG_FILE="$BASE_DIR/mysite-backup.log"

# Exclude Patterns
EXCLUDE=(
    "cache"
    "**.log"
    "mycustom/exclude"
    "tmp"
    "**.tmp"
    "specific-file.txt"
    "node_modules"
)

# Backup Configuration
BACKUP_FROM_REMOTE_SITE=false
SRC="/var/www/html/"  # Source directory for local backups
REMOTE_PATH="/var/www/html/"  # This is used for remote backups
REMOTE_PORT=22
SSH_METHOD="key"

# Notification Settings
ENABLE_NOTIFICATIONS=true
NOTIFY_ON_FAILURE=true
NOTIFY_ON_SUCCESS=true
EMAIL_SCRIPT="$BASE_DIR/send_notification.sh"

# Email Method
EMAIL_METHOD="postmark" # Set to "smtp" or "postmark"

# SMTP Configuration (non-sensitive parts)
SMTP_SERVER="smtp.example.com"
SMTP_PORT=587

# Postmark Configuration (non-sensitive parts)
POSTMARK_API_URL="https://api.postmarkapp.com/email"
```

### Environment File

Create a `.env` file in the same directory as your scripts for sensitive information. Here's an example:

```plaintext
# Remote Backup Configuration
REMOTE_IP=10.11.0.109
REMOTE_USER=backup-user
SSH_KEY=/root/.ssh/site-backups

# SMTP Configuration (if needed)
SMTP_USER=your_email@example.com
SMTP_PASS=your_email_password

# Postmark Configuration
POSTMARK_TOKEN=your-postmark-token-here

# Email Addresses
FROM_EMAIL=your_email@example.com
TO_EMAIL=admin@example.com
```

Ensure the `.env` file is secure:
```bash
chmod 600 .env
```

### Configuring Exclusions

In the `settings.sh` file, you can configure files and directories to exclude from the backup:

```bash
EXCLUDE=(
    "cache"                         # Exclude a directory named 'cache' anywhere in the backup
    "**.log"                        # Exclude all files with .log extension in any directory
    "mycustom/exclude"              # Exclude a specific directory
    "tmp"                           # Exclude a directory named 'tmp' anywhere in the backup
    "**.tmp"                        # Exclude all files with .tmp extension in any directory
    "specific-file.txt"             # Exclude a specific file
    "node_modules"                  # Exclude 'node_modules' directories anywhere in the backup
)
```

## Usage

Run the script as root:

```
sudo ./backup_script.sh
```

For automated backups, add the script to root's crontab. For example, to run it daily at 2 AM:

```
0 2 * * * /path/to/backup_script.sh
```

## Logging

The script logs its operations to both the console and a log file (configured in the `settings.sh` file). Check this file for detailed information about each backup run.

## Email Notifications

The script can send email notifications for successful backups and failures. Configure the email settings in the `.env` and `settings.sh` files. You can choose between SMTP and Postmark for sending emails.

## Directory Structure

After running the script, your backup directory structure will look like this:

```
website-rsync-backup/
├── .env
├── settings.sh
├── backup_script.sh
├── send_notification.sh
├── backups/
    ├── daily/
    │   └── YYYY-MM-DD/
    ├── weekly/
    │   └── YYYY-MM-DD/
    └── monthly/
        └── YYYY-MM-DD/
```

## Error Handling

The script includes robust error checking for critical operations:
- Ensures it's run with root privileges.
- Checks for sufficient disk space before starting the backup.
- Logs errors and sends email notifications (if configured) if critical operations fail.

## Troubleshooting

1. **Script fails to run**: 
   - Ensure the script has execute permissions: `chmod +x backup_script.sh`
   - Check if you're running as root: `sudo ./backup_script.sh`

2. **Rsync errors**: 
   - Verify source and destination paths in `settings.sh`
   - Check permissions on source and destination directories

3. **Email notifications not working**: 
   - Verify email settings in `.env` and `settings.sh`
   - Check if mutt is installed for SMTP notifications
   - Ensure curl is installed for Postmark notifications

4. **Remote backups failing**: 
   - Verify SSH key path and permissions
   - Check if the remote user has necessary permissions on the source directory

5. **Disk space errors**: 
   - Adjust `REQUIRED_DISK_SPACE` in `settings.sh` if necessary
   - Free up space on the destination drive

For more detailed troubleshooting, check the log file specified in `settings.sh`.

## Security Considerations

- The `.env` file contains sensitive information. Ensure it has restricted permissions (`chmod 600 .env`) and is not included in version control.
- Use key-based SSH authentication for remote backups for better security.
- Regularly update the script and its dependencies to patch any security vulnerabilities.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Dan-Duran/website-rsync-backup/issues) if you want to contribute.

### Development Path

We're always looking to improve. Here are some areas we're considering for future development:

- Multi-site support with task scheduling to balance server load
- Backup email and notification enhancements (Slack, Microsoft Teams, Discord, SendGrid, etc.)
- Database backup integration (MySQL, PostgreSQL, etc.)
- Incremental and differential backups for saving storage space
- Backup encryption for security
- AWS storage support
- Backup verification to verify the integrity of backups

If you'd like to contribute to any of these areas or have other ideas, please open an issue or submit a pull request!

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

LONG LIVE OPEN SOURCE! Dan Duran @ [GetCyber.me](https://GetCyber.me)
