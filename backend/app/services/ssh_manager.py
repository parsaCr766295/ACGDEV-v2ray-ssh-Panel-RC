import paramiko
from typing import Optional, Dict

class SSHManager:
    def __init__(self):
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    def connect(self, host: str, username: str, key_path: Optional[str] = None, password: Optional[str] = None):
        try:
            if key_path:
                self.client.connect(host, username=username, key_filename=key_path)
            else:
                self.client.connect(host, username=username, password=password)
            return True
        except Exception as e:
            print(f"SSH Connection Error: {e}")
            return False

    def execute_command(self, command: str) -> Dict[str, str]:
        if not self.client.get_transport() or not self.client.get_transport().is_active():
             return {"error": "Not connected"}
        
        stdin, stdout, stderr = self.client.exec_command(command)
        return {
            "stdout": stdout.read().decode().strip(),
            "stderr": stderr.read().decode().strip()
        }

    def close(self):
        self.client.close()

# Example usage within a service
ssh_service = SSHManager()
