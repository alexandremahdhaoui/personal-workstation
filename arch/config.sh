#!/usr/bin/env bash

cache_config() {
  curl -sfL https://raw.githubusercontent.com/alexandremahdhaoui/personal-workstation/main/arch/config.yaml | tee /tmp/arch_config.yaml
}

run_pacman() {
  cat /tmp/arch_config.yaml  | yq '.pacman[]' | xargs pacman -S --noconfirm
}

run_flatpak() {
  # install remotes
  cat /tmp/arch_config.yaml | yq '.flatpak.remote' | sed "s/\://" | xargs -I{} flatpak remote-add --if-not-exists "{}"
  
  # install from remotes
  for remote in $(cat /tmp/arch_config.yaml | yq '.flatpak.remote | keys | .[]'); do
    cat /tmp/arch_config.yaml | yq ".flatpak.${remote}[]" |  xargs -I{} echo flatpak install "${remote}" "{}"
  done
  
  # install flatpaks from flatpakref
  cat /tmp/arch_config.yaml | yq '.flatpak.ref[]' | xargs -I{} flatpak install -y "{}"
}

run_gsettings() {
  cat /tmp/arch_config.yaml | yq '.gsettings[]' | xargs -I{} echo gsettings "{}"
}

run_files() {
  cat /tmp/arch_config.yaml  | yq '.files.home | keys | .[]' | xargs dirname | xargs -I{} echo "${HOME}/{}" |  xargs mkdir -p

  for configpath in $(cat /tmp/arch_config.yaml  | yq '.files.home | keys | .[]'); do
    cat /tmp/arch_config.yaml | yq ".files.home.\"${configpath}\"" | tee "${HOME}/${configpath}"
  done
}

cache_config
run_pacman
run_flatpak
run_gsettings
run_files

