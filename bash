#!/bin/bash

# Read configuration from file
read -r DB_HOST DB_USER DB_PASS DB_BASE BACKUP_PATH BACKUP_PREFIX BACKUP_COUNT <<< $(cat "$1")

# Define the backup command
PGPASSFILE=$HOME/.pgpass
PG OPTIONS="host=$DB_HOST user=$DB_USER password=$DB_PASS dbname=$DB_BASE" pg_dump -F c -f "$BACKUP_PATH/$BACKUP_PREFIX.$(date +%Y-%m-%d).tar.gz" $DB_BASE

# Check the number of backups and delete the oldest if necessary
num_backups=$(ls "$BACKUP_PATH" | grep -E "^\\$BACKUP_PREFIX\\.\\d{4}-\\d{2}-\\d{2}\\.tar\\.gz" | wc -l)
if (( num_backups > BACKUP_COUNT )); then
    oldest_backup=$(ls "$BACKUP_PATH" | grep -E "^\\$BACKUP_PREFIX\\.\\d{4}-\\d{2}-\\d{2}\\.tar\\.gz" | sort | head -n1)
    rm "$oldest_backup"
fi

# Log messages
log_file="$BACKUP_PATH/$BACKUP_PREFIX.$(date +%Y-%m-%d).log"
echo "Backup started at $(date)" >> "$log_file"
if [ $? -eq 0 ]; then
    echo "Backup successful" >> "$log_file"
else
    echo "Backup failed with error code $?" >> "$log_file"
    echo "Error details: $?" >> "$log_file"
    exit 1
fi
echo "Backup ended at $(date)" >> "$log_file"

# Print messages to stdout
cat "$log_file"

# Set up Cron job (for Linux)
# crontab -e
# 0 1 * * 1-5 /path/to/script/backup-sql /path/to/file/config

# Set up Schtasks (for Windows)
# schtasks /create /tn "Backup SQL" /tr "C:\\path\\to\\script\\backup-sql.exe C:\\path\\to\\file\\config" /sc daily /st 01:05 /d " except 6,7"
