#!/usr/bin/env bash

sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'
sudo apt update
sudo apt install --install-recommends winehq-staging
sudo apt install winetricks

# --- STEAM REPO --- #
# https://repo.steampowered.com/steam/
# Trust gpg pub key:
sudo wget https://repo.steampowered.com/steam/archive/stable/steam.gpg -O /usr/share/keyrings/steam.gpg
# Add repo:
cat <<'EOF' | sudo tee /etc/apt/sources.list.d/steam-stable.list
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F24AEA9FB05498B7

# --- GPU DRIVERS --- #
# If NVIDIA:
sudo add-apt-repository ppa:graphics-drivers/ppa && sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install -y nvidia-driver-535 libvulkan1 libvulkan1:i386
# If AMD:
sudo add-apt-repository ppa:kisak/kisak-mesa && sudo dpkg --add-architecture i386 && sudo apt update && sudo apt upgrade && sudo apt install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386

# --- LUTRIS --- #
# Install deps:
sudo apt install libgl1-mesa-dri libglx-dev
# Add repo:
sudo add-apt-repository ppa:lutris-team/lutris
# Install Lutris:
sudo apt update
sudo apt install lutris

# --- PROTON-GE --- #
# Fixes a bug involving apparmor in ubuntu 24.10
cat <<'EOF' | sudo tee /etc/apparmor.d/bwrap && sudo systemctl restart apparmor.service
abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,

  # Site-specific additions and overrides. See local/README for details.
  include if exists <local/bwrap>
}
EOF

# --- WINE-GE --- #
# https://github.com/GloriousEggroll/wine-ge-custom/releases
# Only works on amd64.
VERSION=GE-Proton8-26
NAME="wine-lutris-${VERSION}-x86_64"
TARGET_DIR="${HOME}/.local/share/lutris/runners/wine/"
mkdir -p "${TARGET_DIR}"
URL="https://github.com/GloriousEggroll/wine-ge-custom/releases/download/${VERSION}/${NAME}.tar.xz"
wget -qO- "${URL}" | tar xJv -C "${TARGET_DIR}"

#
#
# 04c0:err:winediag:h264_decoder_create GStreamer doesn't support H.264 decoding, please install appropriate plugins
# 04c0:fixme:ole:CoCreateInstanceEx no instance created for interface {00000000-0000-0000-c000-000000000046} of class {62ce7e72-4c71-4d20-b15d-452831a87d9d}, hr 0x80004005.
# wine: Unhandled page fault on read access to 00000000 at address 104D4C2B (thread 04c0), starting debugger...
# ERROR: ld.so: object 'libgamemodeauto.so.0' from LD_PRELOAD cannot be preloaded (wrong ELF class: ELFCLASS64): ignored.
