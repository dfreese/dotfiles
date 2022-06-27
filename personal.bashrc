#!/bin/bash

export EDITOR="nvim"
alias nv="nvim"

src_tld() {
  local git_tld
  if ! git_tld=`git rev-parse --show-toplevel --quiet 2>/dev/null`; then
    git_tld="."
  fi
  readonly git_tld
  echo "${git_tld}"
}

src_search_paths() {
  local tld
  tld="$(src_tld)"
  readonly tld

  echo "${tld}"
}

skim_src() {
  local -a files
  files=( $(src_search_paths "${tld}") )
  readonly files
  rg --color=always --files "${files[@]}" | sk-tmux
}

# Convinence function to start a fuzzy search in the current repository, or if
# that fails, the current directory.
nf() {
  if file="$(skim_src)"; then
    "${EDITOR}" "${file}"
  fi
}

# Convinence function to start nvim with all of the files that currently have
# a diff.  Any arguments are passed just before the filenames.
nd() {
  "${EDITOR}" $@ $(git diff --name-only)
}

# Convinence function to start nvim with all of the files that currently have
# a diff from upstrem.  Any arguments are passed just before the filenames.
# Very similar to nd.
ndu() {
  "${EDITOR}" $@ $(git diff --name-only $(git rev-parse --abbrev-ref --symbolic-full-name @{u}))
}

source "${HOME}/.cargo/env"

export SKIM_DEFAULT_COMMAND="rg --files"
export SKIM_DEFAULT_OPTIONS="--reverse --height=7 --ansi --color=dark"
export PATH="${PATH}:${HOME}/.skim/bin"

export RIPGREP_CONFIG_PATH="${HOME}/dotfiles/ripgrep.rc"
