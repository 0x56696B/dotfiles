import subprocess


def get_value_from_encrypted_file(file_path, key, vault_password, vault_file_present=False):
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
