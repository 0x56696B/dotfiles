#!/bin/sh

DOTFILES=$HOME/.dotfiles

echo 'Setting up XDG Env Variables...'
$DOTFILES/scripts/set-user-xdg-env-variables.sh
echo 'XDG Env Variables Set!'

# ZSH
echo 'ZSH Config...'
ln -sf $DOTFILES/zshrc $HOME/.zshrc
ln -sf $DOTFILES/zsh $HOME/.zsh
ln -sf $DOTFILES/zfunc $HOME/.zfunc
ln -sf $DOTFILES/zshenv $HOME/.zshenv
echo 'ZSH Config Loaded!'

# BASH
echo 'BASH Config...'
ln -sf $DOTFILES/bashrc $HOME/.bashrc
echo 'BASH Config Loaded!'

# Config
echo 'Dot Config...'
ln -sf $DOTFILES/config $HOME/.config
echo 'Dot Config Loaded!'

# KDE
echo 'KDE Config...'
ln -sf $DOTFILES/kde $HOME/.kde4
echo 'KDE Loaded!'

# TMUX
echo 'TMUX Config...'
ln -sf $DOTFILES/tmux.conf $HOME/.tmux.conf
echo 'TMUX Loaded!'

# NeoVIM
echo 'NeoVIM Config...'
ln -sf $DOTFILES/nvim $HOME/.nvim
echo 'NeoVIM Loaded!'

# Rider
echo 'Rider Config...'
ln -sf $DOTFILES/ideavimrc $HOME/.ideavimrc
echo 'Rider Loaded!'

# Firefox Extension Trydactyl
echo 'Firefox Config...'
ln -sf $DOTFILES/tridactylrc $HOME/.tridactylrc 
echo 'Firefox Loaded!'

# EAA Client config
ln -sf $DOTFILES/edgerc $HOME/.edgerc

# Omnisharp
ln -sf $DOTFILES/omnisharp $HOME/.omnisharp
