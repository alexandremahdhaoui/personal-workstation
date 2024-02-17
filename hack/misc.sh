#!/usr/bin/env bash

errInstall="already installed on this machine..."

flatpak_add_flathub() {
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
}

install_google_chrome()	{
  flatpak install flathub com.google.Chrome &>/dev/null || echo chrome "${errInstall}"
  xdg-settings set default-web-browser com.google.Chrome.desktop
}

install_password_manager() {
  flatpak install https://downloads.1password.com/linux/flatpak/1Password.flatpakref &>/dev/null \
  || echo password manager "${errInstall}"
}

install_source_code_pro() {
  rpm-ostree install adobe-source-code-pro-fonts &>/dev/null || echo source code pro "${errInstall}"
}

update_system_fonts() {
  gsettings set org.gnome.desktop.interface document-font-name  'Source Code Pro'
  gsettings set org.gnome.desktop.interface font-name 'Source Code Pro'
}

install_distrobox() {
  rpm-ostree install distrobox &>/dev/null || echo distrobox already installed on this machine
}

install_workstation() {
  printf "installing workstation...\n"
  TEMP_FILE="$(mktemp)"
  cat <<EOF | tee "${TEMP_FILE}" &>/dev/null
[workstation]
image=fedora:39
replace=true
init_hooks="dnf install -y dnf-command\(copr\) && sudo dnf copr enable -y atim/starship && sudo dnf install -y starship"
additional_packages="git tmux"
exported_bins="/usr/bin/tmux"
exported_bins_path="${HOME}/.local/bin"
start_now=true
EOF
  distrobox assemble create -R --file "${TEMP_FILE}" || exit 1
  printf "DONE ✅\n"
}
