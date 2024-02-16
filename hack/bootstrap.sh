#!/usr/bin/env bash

source "$(dirname ${0})/common.sh"

main() {
  export GOPATH="${HOME}/go"
  export GOBIN="${GOPATH}/bin"
  export PATH="${PATH}:${GOBIN}"
  mkdir -p "${GOBIN}"

  ALEXANDRE_MAHDHAOUI_DIR="${GOPATH}/github.com/alexandremahdhaoui"
  mkdir -p "${ALEXANDRE_MAHDHAOUI_DIR}"

  go_install

  tmux_default_shell
  tmux_conf

  ssh_generate_keys
  ssh_add_identity
  github_upload_public_key

  clone_data_repo "${ALEXANDRE_MAHDHAOUI_DIR}"

  vib_install
  vib_config

  bashrc
  gitconfig
}

main
