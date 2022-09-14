#!/bin/bash
set -e
USER_ID=$(id -u $USER)
GROUP_ID=$(id -g $USER)
function create_service() {
    service=$(
    cat <<EndOfMessage
# This service unit is for creating Backups of the system
# By Marcel Herhold

[Unit]
Description=Backups sensible data to hard drive
Wants=myBackup.timer

[Service]
Type=oneshot
User=$USER_ID
ExecStart=/opt/backup/main.py

[Install]
WantedBy=multi-user.target
EndOfMessage
  )
    echo "$service" > myBackup.service
    sudo mv myBackup.service /etc/systemd/system/myBackup.service
}

BACKUP_FOLDER=/opt/backup
sudo mkdir -p $BACKUP_FOLDER
sudo chown -R $USER_ID:$GROUP_ID $BACKUP_FOLDER
cp ~/backup_config.json $BACKUP_FOLDER
cp *.py $BACKUP_FOLDER
chmod +x $BACKUP_FOLDER/*.py
cp requirements.txt $BACKUP_FOLDER

sudo pip3 install -r ${BACKUP_FOLDER}/requirements.txt
sudo cp systemd/myBackup.timer /etc/systemd/system/
create_service
sudo systemctl enable myBackup.service
sudo systemctl enable myBackup.timer
sudo systemctl start myBackup.timer
