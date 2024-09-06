import subprocess
import os
import sys

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
