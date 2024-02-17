#!/usr/bin/env bash

errInstall="already installed on this machine..."

flatpak_add_flathub() {
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_google_chrome()	{
  flatpak install flathub com.google.Chrome || echo chrome "${errInstall}"
  xdg-settings set default-web-browser com.google.Chrome.desktop
}

install_password_manager() {
  flatpak install https://downloads.1password.com/linux/flatpak/1Password.flatpakref \
  || echo password manager "${errInstall}"
}

install_source_code_pro() {
  rpm-ostree install adobe-source-code-pro-fonts || echo source code pro "${errInstall}"
}

update_system_fonts() {
  gsettings set org.gnome.desktop.interface document-font-name  'Source Code Pro'
  gsettings set org.gnome.desktop.interface font-name 'Source Code Pro'
}

install_distrobox() {
  rpm-ostree install distrobox || echo distrobox already installed on this machine
}

install_tools() {
  echo skipping tools...
#  TEMP_FILE="$(mktemp)"
#  cat <<EOF | tee "${TEMP_FILE}"
#[tools]
#image=fedora:39
#replace=true
#additional_packages="tmux"
#exported_bins="/usr/bin/tmux"
#exported_bins_path="/var/home/alexandremahdhaoui/.local/bin"
#start_now=true
#EOF
#  distrobox assemble create -R --file "${TEMP_FILE}"
}
