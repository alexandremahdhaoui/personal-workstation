#!/usr/bin/env bash

rpm_ostree_install() {
  rpm-ostree install --apply-live --allow-inactive \
    1password     \
    1password-cli \
    arp-scan      \
    libvirt       \
    qemu-kvm      \
    sysstat       \
    tcpdump       \
    tmux          \
    virt-install  \
    virt-viewer
#    golang        \
}

go_install() {
  CPU_FAMILY=$(arch)
  if [ "${CPU_FAMILY}" == "x86_64" ]; then CPU_FAMILY="amd64";fi
  if [ "${CPU_FAMILY}" == "aarch64" ]; then CPU_FAMILY="arm64";fi


  printf "Checking latest Go version...\n";
  LATEST_GO_VERSION="$(curl -sfL https://go.dev/VERSION?m=text | head -n 1)";
  GO_URL="https://go.dev/dl/${LATEST_GO_VERSION}.linux-${CPU_FAMILY}.tar.gz"

  printf "cd to home (%s) directory \n" "${USER}"
  cd "${HOME}" || exit 1

  printf "Downloading %s\n\n" "${GO_URL}";
  curl -OJ -L --progress-bar "${GO_URL}"

  printf "Extracting file...\n"
  tar -xf "${LATEST_GO_VERSION}.linux-${GO_URL}.tar.gz"

  go version
}

tmux_default_shell() {
  chsh -s /usr/bin/tmux
}

tmux_conf() {
  cat <<EOF | tee "${HOME}/.config/.tmux.conf"
set-option -g default-shell /usr/bin/bash
EOF
}

ssh_generate_keys() {
  echo "Generating ssh keys..."
  ssh-keygen -t ed25519 -C "alexandre.mahdhaoui@gmail.com"
}

ssh_add_identity() {
  ssh-add
}

github_upload_public_key() {
  xdg-open https://github.com/settings/keys &>/dev/null
  read -p "Please upload your ssh public key to github.com

Opening https://github.com/settings/keys

Public key:    $(cat "${HOME}/.ssh/id_ed25519.pub")

PRESS ENTER TO CONTINUE"
}

clone_data_repo() {
  DEST_DIR="${1}"
  (
    cd "${DEST_DIR}" || { echo "Failed changing directory to \"${DEST_DIR}\"" && exit 1 ; }
    git clone git@github.com:alexandremahdhaoui/data.git
  )
}

vib_install() {
  go install github.com/alexandremahdhaoui/vib@latest
  vib render thiswillfail &>/dev/null
}

vib_config() {
  cat <<EOF | tee "${HOME}/.config/vib/vib.alexandre.mahdhaoui.com_v1alpha1.config.config.yaml"
apiVersion: vib.alexandre.mahdhaoui.com/v1alpha1
kind: Config
metadata:
    name: config
spec:
    operatorstrategy: filesystem
    resourcedir: ${ALEX_DIR}/data/vib
EOF
}

bashrc() {
  cat <<'EOF' | tee -a "${HOME}/.bashrc"

  if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
  fi

export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
export PATH="${PATH}:${GOBIN}"

. <(vib render profile fcos)
EOF
}

gitconfig() {
  cat <<EOF | tee "${HOME}/.gitconfig"
[user]
        email = alexandre.mahdhaoui@gmail.com
        name = Alexandre Mahdhaoui
[core]
        excludesfile = /var/home/alex/.gitignore
[init]
        defaultBranch = main
[url "git@github.com:alexandremahdhaoui"]
        insteadOf = https://github.com/alexandremahdhaoui
EOF

  cat <<EOF | tee -a "${HOME}/.gitignore"
.idea
nohup.out
EOF
}

main() {
  export GOPATH="${HOME}/go"
  export GOBIN="${GOPATH}/bin"
  export PATH="${PATH}:${GOBIN}"
  mkdir -p "${GOBIN}"

  ALEXANDRE_MAHDHAOUI_DIR="${GOPATH}/github.com/alexandremahdhaoui"
  mkdir -p "${ALEX_DIR}"

  rpm_ostree_install
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
