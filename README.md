# Website Rsync Backup Automation Script

This repository contains an enhanced Bash script for automating website backups using rsync. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently, and includes configurable email notifications for backup successes and failures.

## HELP!

Feel free to contribute to this repo! All adjustments and comments are welcomed. Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/Dan-Duran/website-rsync-backup/issues) if you want to contribute.

## Features

- Daily backups with custom retention (default: 90 days)
- Weekly backups (on Sundays) with custom retention (default: 52 weeks)
- Monthly backups (on the 1st of each month) with custom retention (default: 24 months)
- Automatic rotation to remove old backups
- Uses rsync for efficient, incremental backups
- Customizable file and directory exclusions
- Comprehensive error handling and logging
- Disk space check before backup (default 1GB)
- Root privilege check
- Configurable email notifications for backup successes and failures via SMTP or Postmark
- Option to completely disable email notifications

## Prerequisites

- Bash shell
- rsync
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

1. Edit the `backup_script.sh` file to set your backup configuration:
   - `SITE`: Name of your site (used in notifications)
   - `SRC`: The directory you want to backup
   - `DEST_BASE`: The base directory where backups will be stored
   - `LOG_FILE`: Path to the log file
   - `RETENTION_DAILY`, `RETENTION_WEEKLY`, `RETENTION_MONTHLY`: Retention periods for each backup type
   - `EMAIL_SCRIPT`: Path to the send_notification.sh script (should be "./send_notification.sh" if in the same directory)
   - `EXCLUDE`: Array of files and directories to exclude from the backup
   - `ENABLE_NOTIFICATIONS`: Set to `true` to enable email notifications, or `false` to disable them completely
   - `NOTIFY_ON_FAILURE`: Set to `true` to receive emails on backup failures (if notifications are enabled)
   - `NOTIFY_ON_SUCCESS`: Set to `true` to receive emails on successful backups (if notifications are enabled)

2. Configure exclusions in the `EXCLUDE` array:
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

3. If email notifications are enabled, edit the `send_notification.sh` file to configure email settings.

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

The script logs its operations to both the console and a log file (default: `/var/log/mysite-backup.log`). Check this file for detailed information about each backup run.

## Email Notifications

[The email notifications section remains the same as in your original README]

## Directory Structure

After running the script, your backup directory structure will look like this:

```
website-rsync-backup/
├── backup_script.sh
├── send_notification.sh
├── backups/
    ├── daily/
    ├── weekly/
    └── monthly/
```

## Error Handling

The script includes error checking for critical operations:
- Ensures it's run with root privileges
- Checks for sufficient disk space before starting the backup
- Logs errors and sends email notifications (if configured) if critical operations fail

## Security Considerations

- The `send_notification.sh` script contains sensitive email credentials. Ensure it has restricted permissions (`chmod 700 send_notification.sh`).
- Consider using environment variables or a separate configuration file for sensitive information.

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

LOVING OPEN SOURCE. Dan Duran @ GetCyber! - [GitHub Profile](https://github.com/Dan-Duran)
