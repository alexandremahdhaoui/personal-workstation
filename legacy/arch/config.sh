#!/usr/bin/env bash

CONFIG_PATH="${HOME}/.config.yaml"

cache_config() {
    curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/config.yaml | tee "${CONFIG_PATH}"
}

run_pacman() {
    yq '.pacman[]' "${CONFIG_PATH}" | xargs sudo pacman -S --noconfirm
}

run_flatpak() {
    # install remotes
    yq '.flatpak.remote' "${CONFIG_PATH}" | sed "s/\://" | xargs -n 2 flatpak remote-add --if-not-exists

    # install from remotes
    for remote in $(yq '.flatpak.remote | keys | .[]' "${CONFIG_PATH}"); do
        yq ".flatpak.${remote}[]" "${CONFIG_PATH}" | xargs -I{} sudo flatpak install -y "${remote}" {}
    done

    # install flatpaks from flatpakref
    yq '.flatpak.ref[]' "${CONFIG_PATH}" | xargs sudo flatpak install -y
}

run_gsettings() {
    # shellcheck disable=SC2016
    yq '.gsettings[]' "${CONFIG_PATH}" | xargs bash -c 'gsettings $0'
}

run_files() {
    yq '.files.home | keys | .[]' "${CONFIG_PATH}" | xargs dirname | xargs -I{} echo "${HOME}/{}" | xargs mkdir -p

    for filePath in $(yq '.files.home | keys | .[]' "${CONFIG_PATH}"); do
        yq ".files.home.\"${filePath}\"" "${CONFIG_PATH}" | tee "${HOME}/${filePath}"
    done
}

cache_config
run_pacman
run_flatpak
run_gsettings
run_files
