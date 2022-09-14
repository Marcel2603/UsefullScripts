import os
import subprocess

from smb.SMBConnection import SMBConnection


class SambaConnection:
    def __init__(self, domain, host, host_name, username, password, user_client_name, sharename):
        self.domain = domain
        self.host = host
        self.host_name = host_name
        self.username = username
        self.password = password
        self.user_client_name = user_client_name
        self.sharename = sharename
        self.server = SMBConnection(
            self.username,
            self.password,
            self.user_client_name,
            self.host_name,
            self.domain,
            sign_options=SMBConnection.SIGN_WHEN_SUPPORTED,
            is_direct_tcp=False
        )

    def list(self):
        self.server.connect(self.host, 139)
        filelist = self.server.listPath(self.sharename, f"/{self.username}/backup/")
        filenames = []
        for file in filelist:
            filenames.append(file.filename)
        filenames.sort()
        return filenames

    def delete(self, file_to_delete):
        self.server.connect(self.host, 139)
        self.server.deleteFiles(self.sharename, f"/{self.username}/backup/{file_to_delete}")

    def upload_file(self, share, file_path):
        self.server.connect(self.host, 139)
        with open(file_path, "rb") as file:
            file_name = os.path.basename(file.name)
            self.server.storeFile(share, f"/{self.username}/backup/{file_name}", file_obj=file)

    def ping_host(self):
        print(f"Ping host {self.host_name}")
        response = subprocess.run(["ping", "-c", "1", self.host], stdout=open(os.devnull, 'wb')).returncode
        print(f"Host up? {response == 0}")
        # and then check the response...
        return response == 0
