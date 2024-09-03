# Website Rsync Backup Automation Script

This repository contains a Bash script for automating backups using rsync for your website. The script performs daily, weekly, and monthly backups with rotation to manage storage efficiently.

## Features

- Daily backups with custom retention (default: 90 days)
- Weekly backups (on Sundays) with custom retention (default: 52 weeks)
- Monthly backups (on the 1st of each month) with custom retention (default: 24 months)
- Automatic rotation to remove old backups
- Uses rsync for efficient, incremental backups

## Prerequisites

- Bash shell
- rsync
- cron (for scheduling)

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

Edit the `backup_script.sh` file to set your source and destination directories:

- `SRC`: The directory you want to backup
- `DEST_BASE`: The base directory where backups will be stored

You can also adjust the rotation limits for each backup type (daily, weekly, monthly) by modifying the respective values in the `rotate` function calls.

## Usage

You can run the script manually:

```
./backup_script.sh
```

For automated backups, add the script to your crontab. For example, to run it daily at 2 AM:

```
0 2 * * * /path/to/backup_script.sh
```

## Directory Structure

After running the script, your backup directory structure will look like this:

```
mysite-backups/
├── backup_script.sh
├── daily/
├── weekly/
└── monthly/
```

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check [issues page](https://github.com/Dan-Duran/website-rsync-backup/issues) if you want to contribute.

## Author

Dan Duran - [GitHub Profile](https://github.com/Dan-Duran)
