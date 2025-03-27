#!/bin/bash
set -euo pipefail

SRC_DIR=$(readlink -f "$(dirname "$0")")
readonly SRC_DIR
DST_DIR="${1:-$HOME}"
readonly DST_DIR
BAK_DIR="${SRC_DIR}.bak"
readonly BAK_DIR

confirm() {
  read -r -p "${1:-Are you sure?} [y/N]" response
  case $response in
    [yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

backup() {
  if [[ -z $1 ]]; then
    echo "Backing up a file requires an input..."
    exit 1
  fi
  if ! [[ -d "${BAK_DIR}" ]]; then
    mkdir "${BAK_DIR}"
  fi
  if [[ -e $1 ]]; then
    mv -f $1 "${BAK_DIR}/"
  fi
}

update_link() {
  backup $2
  rm -f $2
  ln -rs $1 $2
}

install_deps() {
  echo "--------------------- installing deps -------------------------"
  sudo apt-get -y install neovim python3-dev cmake
}

install_rc_files() {
  echo "--------------------- installing rc files ---------------------"

  mkdir -p "${DST_DIR}/.config"

  echo "Updating git configuration"
  update_link "${SRC_DIR}/.gitconfig" "${DST_DIR}/.gitconfig"
  update_link "${SRC_DIR}/global.gitignore" "${DST_DIR}/.gitignore"

  echo "Updating .clang-format"
  update_link "${SRC_DIR}/.clang-format" "${DST_DIR}/.clang-format"

  echo "Updating rustfmt config"
  mkdir -p "${DST_DIR}/.config/rustfmt"
  update_link "${SRC_DIR}/rustfmt.toml" "${DST_DIR}/.config/rustfmt/rustfmt.toml"

  echo "Updating vim and neovim configuration"
  update_link "${SRC_DIR}/importable.vim" "${DST_DIR}/.vimrc"
  mkdir -p "${DST_DIR}/.config/nvim"
  update_link "${SRC_DIR}/importable.vim" "${DST_DIR}/.config/nvim/init.vim"
  mkdir -p "${DST_DIR}/.vim"

  echo "Updating .ycm_extra_conf.py"
  update_link "${SRC_DIR}/.ycm_extra_conf.py" "${DST_DIR}/.ycm_extra_conf.py"

  echo "Updating .tmux.conf"
  update_link "${SRC_DIR}/.tmux.conf" "${DST_DIR}/.tmux.conf"
  update_link "${SRC_DIR}/.tmuxline.conf" "${DST_DIR}/.tmuxline.conf"

  echo "Cloning tmux plugin manager."
  backup "${DST_DIR}/.tmux/plugins/tpm"
  git clone "https://github.com/tmux-plugins/tpm" "${DST_DIR}/.tmux/plugins/tpm"
}

confirm "Setup using ${SRC_DIR}?"
confirm "Install to ${DST_DIR}?"

if [[ -d "${BAK_DIR}" ]]; then
  confirm "Delete ${BAK_DIR}?"
  rm -rf "${BAK_DIR}"
fi

confirm "Install dependencies?" && install_deps
confirm "Install rust?" && curl https://sh.rustup.rs -sSf | sh
confirm "Install rc files?" && install_rc_files
