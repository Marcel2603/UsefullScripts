#!/usr/bin/python3
import datetime
import os
import sys
import tarfile
from subprocess import check_call

restore_script = "$HOME/bitbucket/myProjects/python/myBackup/restore.sh"
backup_destination = "/media/m.herhold/backup/backup/"
backup_name = "myBackup"
paths = [
    restore_script
]

def backup_files():
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_destination + str(now) + '_' + backup_name + '.tar.gz')
    with tarfile.open(backup_zip, "w:gz") as tar:
        for path in paths:
            file_no_envs = os.path.expandvars(path)
            destination = os.path.expandvars(path.replace("$HOME/", ""))
            tar.add(file_no_envs, arcname=destination)
            print('Compress {} to {}'.format(file_no_envs, destination))


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
