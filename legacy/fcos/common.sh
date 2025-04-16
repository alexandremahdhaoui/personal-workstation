#!/usr/bin/env bash

go_install() {
    GO_INSTALL_DEST="${HOME}/.local/share"
    CPU_FAMILY=$(arch)
    if [ "${CPU_FAMILY}" == "x86_64" ]; then CPU_FAMILY="amd64"; fi
    if [ "${CPU_FAMILY}" == "aarch64" ]; then CPU_FAMILY="arm64"; fi

    LATEST_GO_VERSION="$(curl -sfL https://go.dev/VERSION?m=text | head -n 1)"
    GO_DOWNLOAD_URL="https://go.dev/dl/${LATEST_GO_VERSION}.linux-${CPU_FAMILY}.tar.gz"

    cd "${HOME}" || exit 1

    printf "Installing %s... " "${GO_DOWNLOAD_URL}"
    curl -sfL --progress-bar "${GO_DOWNLOAD_URL}" | tar -C "${GO_INSTALL_DEST}" -xz

    ln -sf "${GO_INSTALL_DEST}/go/bin/go" "${HOME}/.local/bin"
    if go version &>/dev/null; then printf "DONE ✅\n"; fi
}

tmux_default_shell() {
    TMUX_BIN="${HOME}/.local/bin/tmux"
    echo "${TMUX_BIN}" | sudo tee -a /etc/shells
    chsh -s "${TMUX_BIN}"
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
    printf "\n---\n"
    read -p "Please upload your ssh public key to github.com

Opening https://github.com/settings/keys

Public key:    $(cat "${HOME}/.ssh/id_ed25519.pub")

PRESS ENTER TO CONTINUE"
}

clone_data_repo() {
    DEST_DIR="${1}"

    (
        cd "${DEST_DIR}" || { echo "Failed changing directory to \"${DEST_DIR}\"" && exit 1; }
        git clone git@github.com:alexandremahdhaoui/data.git || echo github.com:alexandremahdhaoui/data.git already cloned
        cd ./data || exit 1
        git switch t480
    )
}

vib_install() {
    go install github.com/alexandremahdhaoui/vib/cmd/vib@latest
    vib render thiswillfail &>/dev/null
}

vib_config() {
    DEST_DIR="${1}"

    cat <<EOF | tee "${HOME}/.config/vib/vib.alexandre.mahdhaoui.com_v1alpha1.config.config.yaml"
apiVersion: vib.alexandre.mahdhaoui.com/v1alpha1
kind: Config
metadata:
    name: config
spec:
    operatorstrategy: filesystem
    resourcedir: ${DEST_DIR}/data/vib
EOF
}

bashrc() {
    cat <<'EOF' | tee -a "${HOME}/.bashrc"

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

export EDITOR=vi

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
        excludesfile = ${HOME}/.gitignore
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
