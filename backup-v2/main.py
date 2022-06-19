#!/usr/bin/python3
import datetime
import json
import os
import sys
import tarfile
from subprocess import check_call

from samba import SambaConnection

restore_script = "link to restore.sh"
backup_destination = ""
backup_name = "myBackup"
paths = [
    restore_script
]

domain = ""
host = ""
host_name = ""
client_name = ""
username = ""
password = ""

def _load_config():
    with open("config.json") as configfile:
        config = json.load(configfile)
        paths = config["paths"]
        restore_script = config["restoreScript"]
        backup_destination = config["backupDestination"]
    return {
        'paths': paths,
        'restore_script': restore_script,
        'backup_destination': backup_destination
    }

def backup_files():
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_destination + str(now) + '_' + backup_name + '.tar.gz')
    with tarfile.open(backup_zip, "w:gz") as tar:
        for path in paths:
            file_no_envs = os.path.expandvars(path)
            destination = os.path.expandvars(path.replace("$HOME/", ""))
            print('Compress {} to {}'.format(file_no_envs, destination))
            tar.add(file_no_envs, arcname=destination)
    sambaCon = SambaConnection(domain, host, host_name, username, password, client_name)
    if sambaCon.ping_host():
        sambaCon.upload_file("", backup_zip)


def restore():
    tar_name = input('Pls insert filename (no extension)').replace('.tar', '').replace('.gz', '')
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_destination + str(now) + '_' + tar_name + '.tar.gz')

    with tarfile.open(backup_zip) as tar_file:
        tar_file.extractall(os.path.expandvars('$HOME'))

    check_call(['bash', os.path.expandvars(restore_script), 'main'])


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    args = sys.argv
    # args[0] = current file
    # args[1] = function name
    if len(args) > 1 and args[1] == "restore":
        restore()
    else:
        backup_files()