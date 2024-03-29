#!/usr/bin/python3
import datetime
import json
import time
import os
import sys
import tarfile
from subprocess import check_call

from samba import SambaConnection

backup_name = "mybackup"
restore_script = "/opt/backup/restore.sh"
location_of_config = "/home/f.goehring/backup_config.json"
maximum_backups = 10


def _load_config():
    with open(location_of_config) as configfile:
        config = json.load(configfile)
        backup_conf = config["backup"]
        samba_conf = config["samba"]
        return {
            'backup_conf': backup_conf,
            'samba_conf': samba_conf
        }


def backup_files():
    now = datetime.date.today().strftime('%Y_%m_%d')
    path = backup_conf['destination']
    if not os.path.exists(path):
        os.makedirs(path)
    backup_zip = os.path.expandvars(path + str(now) + '_' + backup_name + '.tar.xz')
    with tarfile.open(backup_zip, "w:xz") as tar:
        for path in backup_conf['paths']:
            file_no_envs = os.path.expandvars(path)
            destination = os.path.expandvars(path.replace("$HOME/", ""))
            print('Compress {} to {}'.format(file_no_envs, destination))
            tar.add(file_no_envs, arcname=destination)
    print("Backup to local data finished")
    samba_conf = config['samba_conf']
    if samba_conf['enabled']:
        samba_upload(samba_conf, backup_zip)


def samba_clear():
    filenames = samba_list()
    while len(filenames) > maximum_backups + 2:
        filenames = samba_list()
        samba_delete(filenames[2])
    else:
        print("No more remote files to delete")


def local_clear():
    filenames = os.listdir(backup_conf['destination'])
    filenames.sort()
    while len(filenames) > maximum_backups + 2:
        filenames = os.listdir(backup_conf['destination'])
        filenames.sort()
        local_delete(filenames[2])
    print("No more local files to delete")


def local_delete(filename):
    os.remove('{}{}'.format(backup_conf['destination'], filename))


def samba_upload(samba_conf, backup_zip):
    sambaCon = SambaConnection(
        samba_conf["domain"],
        samba_conf["host"],
        samba_conf["host_name"],
        samba_conf["username"],
        samba_conf["password"],
        samba_conf["client_name"],
        samba_conf["share_name"]
    )
    for tries in range(2):
        if sambaCon.ping_host():
            print("Upload to samba")
            sambaCon.upload_file(samba_conf["share_name"], backup_zip)
            print("Upload completed")
            break
        else:
            print("No connection, waiting for try {}...".format(tries + 2))
            time.sleep(300)


def samba_delete(file_to_delete):
    samba_conf = config['samba_conf']
    sambaCon = SambaConnection(
        samba_conf["domain"],
        samba_conf["host"],
        samba_conf["host_name"],
        samba_conf["username"],
        samba_conf["password"],
        samba_conf["client_name"],
        samba_conf["share_name"]
    )
    if sambaCon.ping_host():
        print("Delete file {}".format(file_to_delete))
        return sambaCon.delete(file_to_delete)


def samba_list():
    samba_conf = config['samba_conf']
    sambaCon = SambaConnection(
        samba_conf["domain"],
        samba_conf["host"],
        samba_conf["host_name"],
        samba_conf["username"],
        samba_conf["password"],
        samba_conf["client_name"],
        samba_conf["share_name"]

    )
    if sambaCon.ping_host():
        return sambaCon.list()


def restore():
    tar_name = input('Pls insert filename (no extension)').replace('.tar', '').replace('.gz', '')
    now = datetime.date.today().strftime('%Y_%m_%d')
    backup_zip = os.path.expandvars(backup_conf['destination'] + str(now) + '_' + tar_name + '.tar.gz')

    with tarfile.open(backup_zip) as tar_file:
        tar_file.extractall(os.path.expandvars('$HOME'))

    check_call(['bash', os.path.expandvars(restore_script), 'main'])


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    config = _load_config()
    backup_conf = config['backup_conf']
    args = sys.argv
    # args[0] = current file
    # args[1] = function name
    if len(args) > 1 and args[1] == "restore":
        restore()
    else:
        backup_files()
        samba_clear()
        local_clear()
