#!/usr/bin/env bash

GOPATH="${HOME}/go"
GOBIN="${GOPATH}/bin"
mkdir -p "${GOBIN}"

install_packages() {
  echo "Installing packages..."
  OS_ID="$(sed -n 's/^ID=\(\w\)/\1/p' /etc/os-release)"
  "$(git rev-parse --showtop-level)/${OS_ID}/packages.sh"
}

ssh_generate_keys() {
  echo "Generating ssh keys..."
  read -rp "Please enter your email: " email
  ssh-keygen -t ed25519 -C "${email}"
}

ssh_add_identity() {
  ssh-add
}

github_upload_public_key() {
  xdg-open https://github.com/settings/keys &>/dev/null
  printf "\n---\n"
  read -rp "Please upload your ssh public key to github.com

Opening https://github.com/settings/keys

Public key:    $(cat "${HOME}/.ssh/id_ed25519.pub")

PRESS ENTER TO CONTINUE"
}

clone_data_repo() {
  read -rp "Please enter your github user: (e.g. 'alexandremahdhaoui') " github_user
  read -rp "Please enter the name of your data repository: (e.g. 'data') " data_repo
  read -rp "Please enter the branch you want to switch to: (e.g. 'main') " data_branch

  DEST_DIR="${GOPATH}/src/github.com/${github_user}/${data_repo}"
  REPO_ADDR="git@github.com:${github_user}/${data_repo}.git"
  mkdir -p "$(dirname "${DEST_DIR}")"

  (
    cd "$(dirname "${DEST_DIR}")" || { echo "Failed changing directory to \"${DEST_DIR}\"" && exit 1; }
    git clone "${REPO_ADDR}" || { echo "Failed cloning repository \"${REPO_ADDR}\"" && exit 1; }
    cd ./data || exit 1
    git switch "${data_branch}" || { echo "Failed switching to branch \"${data_branch}\"" && exit 1; }
  )
}

install_vib() {
  go install github.com/alexandremahdhaoui/vib/cmd/vib@latest
  vib render thiswillfail &>/dev/null # this install vib config.
}

install_nvim() {
  mkdir -p "${HOME}/.local"
  curl -sfL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz | tar -xzC "${HOME}/.local" --strip-components=1
}

install_tmux_tpm() {
  mkdir -p "${HOME}/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
}

install_chezmoi() {
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin" init --apply git@github.com:alexandremahdhaoui/personal-dotfiles.git
}

install_gopackages() {
  go install github.com/nametake/golangci-lint-langserver@06bb2d79c545dc3beabbe9327843897cbe8eb43a
  go install github.com/mikefarah/yq/v4@v4.44.5
  go install mvdan.cc/gofumpt@v0.7.0
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2
  go install github.com/segmentio/golines@latest
}

install_packages
ssh_generate_keys
ssh_add_identity
github_upload_public_key
clone_data_repo
install_vib
install_nvim
install_tmux_tpm
install_chezmoi
install_gopackages
