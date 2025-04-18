#!/usr/bin/env bash

{ # install op
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' |
        sudo tee /etc/apt/sources.list.d/1password.list

    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
}

# install packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    1password \
    curl \
    git gnome-tweaks golang-go \
    isc-dhcp-client \
    luarocks \
    make \
    nodejs npm \
    python3 \
    ripgrep \
    tcpdump tmux tree \
    xclip

# python deps
sudo apt-get install -y pipx
pipx install ruff mypy black
