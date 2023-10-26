#!/usr/bin/env bash

rpm_ostree_install() {
  rpm-ostree install --apply-live --allow-inactive \
    1password     \
    1password-cli \
    arp-scan      \
    golang        \
    libvirt       \
    qemu-kvm      \
    sysstat       \
    tcpdump       \
    tmux          \
    virt-install  \
    virt-viewer
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
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
export PATH="${PATH}:${GOBIN}"

. <(vib render profile fcos)
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

  tmux_default_shell
  tmux_conf

  ssh_generate_keys
  ssh_add_identity
  github_upload_public_key

  clone_data_repo "${ALEXANDRE_MAHDHAOUI_DIR}"

  vib_install
  vib_config

  bashrc
}

main
