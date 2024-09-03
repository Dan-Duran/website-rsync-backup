# Website Rsync Backup Automation Script

This repository contains an enhanced Bash script for automating website backups using rsync. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently, and includes configurable email notifications for backup successes and failures.

## HELP! (CONTRIBUTIONS)

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
- Option to back up from a remote source over SSH

## Prerequisites

- Bash shell
- rsync
- cron (for scheduling)
- Root access (sudo)
- mutt (only if using SMTP for email notifications)
- curl (for Postmark API calls)
- sshpass (only if using password-based SSH authentication for remote backups)

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
5. (Optional) Install sshpass for password-based SSH authentication:
   ```
   sudo apt-get install sshpass
   ```

## Configuration

1. **Create and Configure `.env` File**:
   Sensitive configurations, including email settings, logging paths, and remote SSH credentials, should be stored in a `.env` file in the same directory as your scripts. Here’s an example of what your `.env` file might look like:

   ```plaintext
   # .env

   # For remote backup configuration
   REMOTE_IP=192.168.1.100
   REMOTE_PORT=22
   REMOTE_USER=username
   REMOTE_PATH=/var/www/html/
   SSH_METHOD=key
   SSH_KEY=/path/to/private/key
   REMOTE_PASSWORD=password

   # Log file
   LOG_FILE=/var/log/mysite-backup.log

   # Email script path
   EMAIL_SCRIPT=/path/to/website-rsync-backup/send_notification.sh

   # Email Method
   EMAIL_METHOD=smtp # Set to "smtp" or "postmark"

   # SMTP Configuration
   SMTP_SERVER=smtp.example.com
   SMTP_PORT=587
   SMTP_USER=your_email@example.com
   SMTP_PASS=your_email_password

   # Postmark Configuration
   POSTMARK_TOKEN=your-postmark-token-here
   POSTMARK_API_URL=https://api.postmarkapp.com/email

   # Common Configuration
   FROM_EMAIL=your_email@example.com
   TO_EMAIL=admin@example.com
   ```

   Ensure the `.env` file is secure:
   ```bash
   chmod 600 .env
   ```

2. **Edit the `backup_script.sh` File**:
   Most of the configurations for the backup process are handled in the script itself. You need to adjust the following in the `backup_script.sh`:

   - `SITE`: Name of your site (used in notifications)
   - `SRC`: The directory you want to back up
   - `DEST_BASE`: The base directory where backups will be stored
   - `RETENTION_DAILY`, `RETENTION_WEEKLY`, `RETENTION_MONTHLY`: Retention periods for each backup type
   - `EXCLUDE`: Array of files and directories to exclude from the backup
   - `ENABLE_NOTIFICATIONS`: Set to `true` to enable email notifications, or `false` to disable them completely
   - `NOTIFY_ON_FAILURE`: Set to `true` to receive emails on backup failures (if notifications are enabled)
   - `NOTIFY_ON_SUCCESS`: Set to `true` to receive emails on successful backups (if notifications are enabled)
   - `REQUIRED_DISK_SPACE`: Required disk space for checking in KB (default: 1GB)
   - `BACKUP_FROM_REMOTE_SITE`: Set to true to enable remote backups, or false for local backups

3. **Configure Exclusions in the `EXCLUDE` Array**:
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

The script logs its operations to both the console and a log file (configured in the `.env` file). Check this file for detailed information about each backup run.

## Email Notifications

Sensitive email settings, including the email method (SMTP or Postmark), are stored in the `.env` file. The `send_notification.sh` script will automatically use these configurations to send emails via the specified method.

## Directory Structure

After running the script, your backup directory structure will look like this:

```
website-rsync-backup/
├── .env
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

- The `.env` file contains sensitive information like email credentials and SSH keys. Ensure it has restricted permissions (`chmod 600 .env`) and is not included in version control.
- Use key-based SSH authentication wherever possible for better security.

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

LONG LIVE OPEN SOURCE! Dan Duran @ [GetCyber.me](https://GetCyber.me)
