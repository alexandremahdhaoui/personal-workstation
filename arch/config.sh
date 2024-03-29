#!/usr/bin/env bash

cache_config() {
  curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/config.yaml | tee /tmp/arch_config.yaml
}

run_pacman() {
  yq '.pacman[]' /tmp/arch_config.yaml | xargs pacman -S --noconfirm
}

run_flatpak() {
  # install remotes
  yq '.flatpak.remote' /tmp/arch_config.yaml | sed "s/\://" | xargs -I{} flatpak remote-add --if-not-exists "{}"
  
  # install from remotes
  for remote in $(yq '.flatpak.remote | keys | .[]' /tmp/arch_config.yaml); do
    yq ".flatpak.${remote}[]" |  xargs -I{} echo flatpak install "${remote}" "{}"
  done
  
  # install flatpaks from flatpakref
  yq '.flatpak.ref[]' /tmp/arch_config.yaml | xargs -I{} flatpak install -y "{}"
}

run_gsettings() {
  yq '.gsettings[]' /tmp/arch_config.yaml | xargs -I{} echo gsettings "{}"
}

run_files() {
  yq '.files.home | keys | .[]' /tmp/arch_config.yaml | xargs dirname | xargs -I{} echo "${HOME}/{}" |  xargs mkdir -p

  for configpath in $(yq '.files.home | keys | .[]' /tmp/arch_config.yaml); do
    yq ".files.home.\"${configpath}\"" | tee "${HOME}/${configpath}"
  done
}

cache_config
run_pacman
run_flatpak
run_gsettings
run_files

