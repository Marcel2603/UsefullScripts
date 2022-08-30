# Backup

## Installation
Copy the `config_example.json` and fill it out (see below). \
After that you can execute the `install.sh` script to enable the automatic backup

## Configuration

The `configuration_example.json` can be adapted to configure your backup routine.

```json
{
  "backup": {
    "destination": "",                       Location of the local backup folder
    "paths": [                               List of strings of files that has to be backuped
        "...",
        ...
    ]
  },
  "samba": {
    "enabled": true,                         If true, the backup will be saved on remote location
    "domain": "EXAMPLE_WORKGROUP",           The domain where the user account is located (e.g.
                                             Workgroup, LOCAL, ...)
    "username": "Some",                      Your username with the right permissions for the share
    "password": "Credentials",               Your password for that
    "client_name": "mycoolpc",               Your pc name
    "host": "123.456.789.0",                 The IP or adress of the server
    "host_name": "thefileservername",        Name of the sharing machine
    "share_name": "sharedSpace"              Name of the share (without subfolder)
  }
}
```

<span style="color:red">**IMPORTANT**: You will store real credentials in this file. Please do *not* commit the file into a git repository!</span>