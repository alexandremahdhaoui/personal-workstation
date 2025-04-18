#!/usr/bin/env bash

# shellcheck disable=SC2086
source <(curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/hack/common.sh)
source <(curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/hack/misc.sh)

main() {
    export GOPATH="${HOME}/go"
    export GOBIN="${GOPATH}/bin"
    export PATH="${PATH}:${GOBIN}"
    mkdir -p "${GOBIN}"
    mkdir -p "${HOME}/.local/bin"

    flatpak_add_flathub
    install_google_chrome
    install_password_manager
    install_source_code_pro
    update_system_fonts
    update_keyboard

    install_workstation

    ALEX_DIR="${GOPATH}/src/github.com/alexandremahdhaoui"
    mkdir -p "${ALEX_DIR}"

    go_install

    tmux_default_shell
    tmux_conf

    ssh_generate_keys
    ssh_add_identity
    github_upload_public_key

    clone_data_repo "${ALEX_DIR}"

    vib_install
    vib_config "${ALEX_DIR}"

    bashrc
    gitconfig
}

main
