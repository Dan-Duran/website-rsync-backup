# Website Rsync Backup Automation Script

This repository contains an enhanced Bash script for automating website backups using rsync. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently.

## Features

- Daily backups with custom retention (default: 90 days)
- Weekly backups (on Sundays) with custom retention (default: 52 weeks)
- Monthly backups (on the 1st of each month) with custom retention (default: 24 months)
- Automatic rotation to remove old backups
- Uses rsync for efficient, incremental backups
- Comprehensive error handling and logging
- Disk space check before backup
- Root privilege check

## Prerequisites

- Bash shell
- rsync
- cron (for scheduling)
- Root access (sudo)

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/Dan-Duran/website-rsync-backup.git
   ```
2. Navigate to the cloned directory:
   ```
   cd website-rsync-backup
   ```
3. Make the script executable:
   ```
   chmod +x backup_script.sh
   ```

## Configuration

Edit the `backup_script.sh` file to set your configuration:

- `SRC`: The directory you want to backup
- `DEST_BASE`: The base directory where backups will be stored
- `LOG_FILE`: Path to the log file
- `RETENTION_DAILY`, `RETENTION_WEEKLY`, `RETENTION_MONTHLY`: Retention periods for each backup type

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

## Directory Structure

After running the script, your backup directory structure will look like this:

```
mysite-backups/
├── backup_script.sh
├── daily/
├── weekly/
└── monthly/
```

## Error Handling

The script includes error checking for critical operations:
- Ensures it's run with root privileges
- Checks for sufficient disk space before starting the backup
- Logs errors and exits if critical operations fail

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/Dan-Duran/website-rsync-backup/issues) if you want to contribute.

## Author

Dan Duran - [GitHub Profile](https://github.com/Dan-Duran)
