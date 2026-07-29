#!/bin/bash

# Пароль для rsync
export RSYNC_PASSWORD="user"

rsync -avz --delete /home/user/DevOps/codeby-devops/lesson8/ backup_user@192.168.31.100::mysql_backup/

if [ $? -eq 0 ]; then
    echo "$(date): Sync completed successfully" >> /var/log/mysql_sync.log
else
    echo "$(date): ERROR: Sync failed!" >> /var/log/mysql_sync.log
    exit 1
fi
