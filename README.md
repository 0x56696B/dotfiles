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

This will setup all lazynvim plugins
