import os
import subprocess
import dark_notify

def switch_kitty_theme(theme):
    if theme == 'dark':
        config_path = os.path.dirname(__file__) + 'kitty-dark.conf'
    else:
        config_path = os.path.dirname(__file__) + 'kitty-light.conf'

    # Construct the command to reload Kitty with the new theme
    command = f"kitty @ --to=unix:/tmp/mykitty set-colors --all --configured {config_path}"
    subprocess.run(command, shell=True)

def on_theme_change(theme):
    print(f"System theme changed to {theme}. Switching Kitty theme.")
    switch_kitty_theme(theme)

# Start listening for dark mode changes
dark_notify.run(on_theme_change)
