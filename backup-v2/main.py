#!/usr/bin/python3
import datetime
import json
import os
import sys
import tarfile
from subprocess import check_call

from samba import SambaConnection

backup_name = "mybackup"
restore_script = "/opt/backup/restore.sh"


def _load_config():
    with open("/opt/backup/config.json") as configfile:
        config = json.load(configfile)
        print(config)
        backup_conf = config["backup"]
        samba_conf = config["samba"]
        return {
            'backup_conf': backup_conf,
            'samba_conf': samba_conf
        }


def backup_files():
    config = _load_config()
    backup_conf = config['backup_conf']
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_conf['destination'] + str(now) + '_' + backup_name + '.tar.gz')
    with tarfile.open(backup_zip, "w:gz") as tar:
        for path in backup_conf['paths']:
            file_no_envs = os.path.expandvars(path)
            destination = os.path.expandvars(path.replace("$HOME/", ""))
            print('Compress {} to {}'.format(file_no_envs, destination))
            tar.add(file_no_envs, arcname=destination)
    samba_conf = config['samba_conf']
    if samba_conf['enabled']:
        sambda_upload(samba_conf, backup_zip)


def sambda_upload(sambda_conf, backup_zip):
    sambaCon = SambaConnection(
        sambda_conf["domain"],
        sambda_conf["host"],
        sambda_conf["host_name"],
        sambda_conf["username"],
        sambda_conf["password"],
        sambda_conf["client_name"]
    )
    if sambaCon.ping_host():
        sambaCon.upload_file("", backup_zip)


def restore():
    config = _load_config()
    backup_conf = config['backup_conf']
    tar_name = input('Pls insert filename (no extension)').replace('.tar', '').replace('.gz', '')
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_conf['destination'] + str(now) + '_' + tar_name + '.tar.gz')

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
