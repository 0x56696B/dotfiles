import subprocess
from helper_scripts import _cmd


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
