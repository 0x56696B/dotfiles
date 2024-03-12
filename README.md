# Commands

## Clone the repo
```bash
git clone --recursive https://github.com/viko-stamoff/dotfiles.git $HOME/.dotfiles
```

## Get the Vault file (vault.secret) in root folder
## Run help
```bash
bin/dotfiles -h
```

## Setup Neovim for first time

After running the Neovim role successfully, run the following command:
```bash
nvim --headless -c 'Lazy sync' -c 'qall'
```
This will install all lazynvim plugins, so they are ready for the first non-headless start

## Setup TMUX for first time

Make sure TPM has been cloned successfully!
Open TMUX and run the command
```bash
$XDG_CONFIG_HOME/.tmux/plugins/tpm/bin/install_plugins
```
