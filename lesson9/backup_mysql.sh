#!/bin/bash

BACKUP_DIR="/home/user/DevOps/codeby-devops/lesson8"
DB_NAME="mydb"
DB_USER="root"
DB_PASSWORD="root"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/mydb_backup_$DATE.sql"

mkdir -p $BACKUP_DIR

mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE 2>/dev/null

if [ $? -eq 0 ]; then
    echo "$(date): Backup created successfully: $BACKUP_FILE" >> /var/log/mysql_backup.log
    
    find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
else
    echo "$(date): ERROR: Backup failed!" >> /var/log/mysql_backup.log
    exit 1
fi
