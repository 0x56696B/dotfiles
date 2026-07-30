import subprocess
import os
import sys
import shutil

DOTFILES_LOG = "dotfiles.log"
LRED = "\033[91m"  # Red color for terminal output


def get_value_from_encrypted_file(
    file_path: str, key: str, vault_password: str, vault_file_present: bool = False
):
    try:
        vault_pass_arg = "--vault-password-file"
        if vault_file_present is False:
            vault_pass_arg = "--ask-vault-password"

        decrypted_content = subprocess.check_output(
            [
                "ansible-vault",
                "view",
                file_path,
                vault_pass_arg,
                vault_password,
            ],
            universal_newlines=True,
        )

        lines = decrypted_content.strip().splitlines()
        for line in lines:
            if ":" in line:
                file_key, file_value = line.split(":", 1)

                parsed_key = file_key.strip()
                parsed_value = file_value.strip()

                if parsed_key == key:
                    return parsed_value

        return ""

    except subprocess.CalledProcessError as e:
        print(f"Error decrypting the file: {e}")
        return ""


def ubuntu_setup():
    if (
        subprocess.run(
            ["dpkg", "-s", "ansible"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing Ansible")
        _cmd("sudo apt-get update")
        _cmd("sudo apt-get install -y software-properties-common")
        _cmd("sudo apt-add-repository -y ppa:ansible/ansible")
        _cmd("sudo apt-get update")
        _cmd("sudo apt-get install -y ansible")
        _cmd("sudo apt-get install python3-argcomplete")
        _cmd("sudo activate-global-python-argcomplete3")

    if (
        subprocess.run(
            ["dpkg", "-s", "python3"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing Python3")
        _cmd("sudo apt-get install -y python3")

    if (
        subprocess.run(
            ["dpkg", "-s", "python3-pip"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing Python3 Pip")
        _cmd("sudo apt-get install python3-pip")


def arch_setup():
    if shutil.which("ansible") is None:
        print("Installing Ansible")
        _cmd("sudo pacman -Sy --noconfirm")
        _cmd("sudo pacman -S --noconfirm ansible")
        _cmd("sudo pacman -S --noconfirm python-argcomplete")

    if (
        subprocess.run(
            ["pacman", "-Q", "python3"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing Python3")
        _cmd("sudo pacman -S --noconfirm python3")

    if (
        subprocess.run(
            ["pacman", "-Q", "python-pip"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing Python3 Pip")
        _cmd("sudo pacman -S --noconfirm python-pip")

    watchdog = subprocess.run(
        ["pip3", "list"], capture_output=True, text=True
    )
    if "watchdog" not in watchdog.stdout:
        print("Installing Python3 Watchdog")
        _cmd("sudo pacman -S --noconfirm python-watchdog")

    if (
        subprocess.run(
            ["pacman", "-Q", "openssh"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        != 0
    ):
        print("Installing OpenSSH")
        _cmd("sudo pacman -S --noconfirm openssh")

    print("Setting Locale")
    _cmd("sudo localectl set-locale LANG=en_US.UTF-8")


def load_setup():
    os_id = ""
    try:
        with open("/etc/os-release") as release_file:
            for line in release_file:
                if line.startswith("ID="):
                    os_id = line.split("=", 1)[1].strip().strip('"')
                    break
    except FileNotFoundError:
        pass

    print(f"Loading Setup for detected OS: {os_id}")
    if os_id == "ubuntu":
        ubuntu_setup()
    elif os_id == "arch":
        arch_setup()
    else:
        print("Unsupported OS")


def _cmd(command: str):
    # Create log if it doesn't exist
    if not os.path.isfile(DOTFILES_LOG):
        open(DOTFILES_LOG, "w").close()

    # Execute the command, hiding stdout, and capturing stderr
    with open(DOTFILES_LOG, "w") as log_file:
        result = subprocess.run(
            command, shell=True, stdout=subprocess.DEVNULL, stderr=log_file
        )

    # If command is successful, return
    if result.returncode == 0:
        return True

    # Print the error and exit
    print(f"{LRED} [X] Command failed: {command}")
    with open(DOTFILES_LOG, "r") as log_file:
        for line in log_file:
            print(f"      {line.strip()}")

    # Remove the log file
    os.remove(DOTFILES_LOG)

    # Exit the script
    sys.exit(1)
