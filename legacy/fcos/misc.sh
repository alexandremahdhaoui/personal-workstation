#!/usr/bin/env bash

errInstall=" already installed on this machine!"

flatpak_add_flathub() {
    printf "adding flathub repo..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
    printf " DONE ✅\n"
}

install_google_chrome() {
    printf "installing google chrome..."
    flatpak install -y flathub com.google.Chrome &>/dev/null || printf "${errInstall}"
    xdg-settings set default-web-browser com.google.Chrome.desktop
    printf " DONE ✅\n"
}

install_password_manager() {
    printf "installing password manager..."
    flatpak install -y https://downloads.1password.com/linux/flatpak/1Password.flatpakref &>/dev/null ||
        printf "${errInstall}"
    printf " DONE ✅\n"
}

install_source_code_pro() {
    printf "installing source code pro..."
    rpm-ostree install -y adobe-source-code-pro-fonts --apply-live &>/dev/null || printf "${errInstall}"
    printf " DONE ✅\n"
}

update_system_fonts() {
    printf "updating system fonts..."
    gsettings set org.gnome.desktop.interface document-font-name 'Source Code Pro'
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
# --- STARSHIP
init_hooks="sudo dnf install -y dnf-command\(copr\)"
init_hooks="sudo dnf copr enable -y atim/starship"
init_hooks="sudo dnf install -y starship"
# --- DEVELOPMENT TOOLS
init_hooks="sudo dnf group install -y "Development Tools""
# --- KUBECTL
init_hooks="curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
init_hooks="chmod 755 kubectl"
init_hooks="mv kubectl ${HOME}/.local/bin/kubectl"
# --- CLUSTER API
init_hooks="curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.6.1/clusterctl-linux-amd64 -o clusterctl"
init_hooks="chmod 0755 clusterctl"
init_hooks="mv clusterctl ${HOME}/.local/bin/clusterctl"
# --- YQ
init_hooks="wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O ${HOME}/.local/bin/yq"
init_hooks="chmod +x ${HOME}/.local/bin/yq"  
# --- DNF packages
additional_packages="git tmux rust cargo helm jq bind-utils net-tools"
# --- Exported Binaries
exported_bins="/usr/bin/tmux"
exported_bins_path="${HOME}/.local/bin"
start_now=true
EOF
    distrobox assemble create -R --file "${TEMP_FILE}" || exit 1
    printf "DONE ✅\n"
}

install_jetbrains_toolbox() {
    printf "installing jetbrains-toolbox"
    sudo dnf install -y fuse fuse-devel &>/dev/null
    BINARY="jetbrains-toolbox"
    VERSION="2.2.1.19765"
    URL="https://download.jetbrains.com/toolbox/${BINARY}-${VERSION}.tar.gz?_ga=2.208160214.53603754.1708527082-621591399.1708527082"
    curl -sfL "${URL}" | tar -xz
    cp -f ./"${BINARY}-${VERSION}/${BINARY}" "${HOME}/.local/bin/"
    rm -rf ./"${BINARY}-${VERSION}"
    printf "DONE ✅\n"
}
