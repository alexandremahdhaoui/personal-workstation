#!/usr/bin/env bash

errInstall=" already installed on this machine!"

flatpak_add_flathub() {
  printf "adding flathub repo..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
  printf " DONE ✅\n"
}

install_google_chrome()	{
  printf "installing google chrome..."
  flatpak install -y flathub com.google.Chrome &>/dev/null || printf "${errInstall}"
  xdg-settings set default-web-browser com.google.Chrome.desktop
  printf " DONE ✅\n"
}

install_password_manager() {
  printf "installing password manager..."
  flatpak install -y https://downloads.1password.com/linux/flatpak/1Password.flatpakref &>/dev/null \
  || printf "${errInstall}"
  printf " DONE ✅\n"
}

install_source_code_pro() {
  printf "installing source code pro..."
  rpm-ostree install -y adobe-source-code-pro-fonts --apply-live &>/dev/null || printf "${errInstall}"
  printf " DONE ✅\n"
}

update_system_fonts() {
  printf "updating system fonts..."
  gsettings set org.gnome.desktop.interface document-font-name  'Source Code Pro'
  gsettings set org.gnome.desktop.interface font-name 'Source Code Pro'
  printf " DONE ✅\n"
}

update_keyboard() {
  printf "replacing caps by escape && swapping ctrl with alt..."
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape,ctrl:swap_lalt_lctl']"
  printf " DONE ✅\n"
}

install_distrobox() {
  printf "installing distrobox..."
  rpm-ostree install -y distrobox --apply-live &>/dev/null || printf "${errInstall}"
  printf " DONE ✅\n"
}

install_workstation() {
  printf "installing workstation...\n"
  TEMP_FILE="$(mktemp)"
  cat <<EOF | tee "${TEMP_FILE}" &>/dev/null
[workstation]
image=fedora:39
replace=true
init_hooks="sudo dnf install -y dnf-command\(copr\) && sudo dnf copr enable -y atim/starship && sudo dnf install -y starship"
init_hooks="sudo dnf group install -y "Development Tools""
additional_packages="git tmux rust cargo"
exported_bins="/usr/bin/tmux"
exported_bins_path="${HOME}/.local/bin"
start_now=true
EOF
  distrobox assemble create -R --file "${TEMP_FILE}" || exit 1
  printf "DONE ✅\n"
}
