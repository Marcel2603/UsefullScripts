import os
import subprocess

from smb.SMBConnection import SMBConnection


class SambaConnection:
    def __init__(self, domain, host, host_name, username, password, user_client_name):
        self.domain = domain
        self.host = host
        self.host_name = host_name
        self.username = username
        self.password = password
        self.user_client_name = user_client_name

    def upload_file(self, share, file_path):
        conn = SMBConnection(self.username, self.password, self.user_client_name, self.host_name, self.domain,
                             sign_options=SMBConnection.SIGN_WHEN_SUPPORTED, is_direct_tcp=False)
        conn.connect(self.host, 139)
        with open(file_path, "rb") as file:
            file_name = os.path.basename(file.name)
            conn.storeFile(share, f"/{self.username}/backup/{file_name}", file_obj=file)

    def ping_host(self):
        print(f"Ping host {self.host_name}")
        response = subprocess.run(["ping", "-c", "1", self.host], stdout=open(os.devnull, 'wb')).returncode
        print(f"Host up? {response == 0}")
        # and then check the response...
        return response == 0
