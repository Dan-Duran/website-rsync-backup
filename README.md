# Website Rsync Backup Automation Script

This repository contains an enhanced Bash script for automating website backups using rsync. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently, and includes configurable email notifications for backup successes and failures.

## Features

- Daily backups with custom retention (default: 90 days)
- Weekly backups (on Sundays) with custom retention (default: 52 weeks)
- Monthly backups (on the 1st of each month) with custom retention (default: 24 months)
- Automatic rotation to remove old backups
- Uses rsync for efficient, incremental backups
- Comprehensive error handling and logging
- Disk space check before backup
- Root privilege check
- Configurable email notifications for backup successes and failures

## Prerequisites

- Bash shell
- rsync
- cron (for scheduling)
- Root access (sudo)
- mutt (for sending emails)

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
4. Install mutt if not already installed:
   ```
   sudo apt-get install mutt
   ```

## Configuration

1. Edit the `backup_script.sh` file to set your backup configuration:
   - `SRC`: The directory you want to backup
   - `DEST_BASE`: The base directory where backups will be stored
   - `LOG_FILE`: Path to the log file
   - `RETENTION_DAILY`, `RETENTION_WEEKLY`, `RETENTION_MONTHLY`: Retention periods for each backup type
   - `EMAIL_SCRIPT`: Path to the send_notification.sh script
   - `NOTIFY_ON_FAILURE`: Set to `true` to receive emails on backup failures
   - `NOTIFY_ON_SUCCESS`: Set to `true` to receive emails on successful backups

2. Edit the `send_notification.sh` file to configure email settings:
   - `SMTP_SERVER`: Your SMTP server address
   - `SMTP_PORT`: Your SMTP server port
   - `SMTP_USER`: Your email username
   - `SMTP_PASS`: Your email password
   - `FROM_EMAIL`: The email address to send notifications from
   - `TO_EMAIL`: The email address to send notifications to

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

The script can send email notifications based on the configuration:

- If `NOTIFY_ON_FAILURE` is set to `true`, emails will be sent in the following failure scenarios:
  - Insufficient disk space before starting the backup
  - Failure during the backup process
  - Failure during the rotation process
  - These emails will be sent with high priority.

- If `NOTIFY_ON_SUCCESS` is set to `true`, an email will be sent when the backup completes successfully.
  - These emails will be sent with normal priority.

All notification emails will include the backup log file as an attachment for detailed information.

You can configure these settings at the top of the `backup_script.sh` file.

## Directory Structure

After running the script, your backup directory structure will look like this:

```
mysite-backups/
├── backup_script.sh
├── send_notification.sh
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

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/Dan-Duran/website-rsync-backup/issues) if you want to contribute.

## Author

Dan Duran - [GitHub Profile](https://github.com/Dan-Duran)
