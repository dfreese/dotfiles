#!/bin/bash

back() {
  cd ${OLDPWD}
}

export EDITOR="nvim"
alias nv="nvim"

# Convinence function to start a fuzzy search in the current repository, or if
# that fails, the current directory.
nf() {
  local git_tld
  if ! git_tld=`git rev-parse --show-toplevel --quiet 2>/dev/null`; then
    git_tld="."
  fi
  readonly git_tld
  local file
  if file="$(rg --files ${git_tld} | sk)"; then
    vim "${file}"
  fi
}

# Convinence function to start nvim with all of the files that currently have
# a diff.  Any arguments are passed just before the filenames.
nd() {
  vim $@ $(git diff --name-only)
}

# Convinence function to start nvim with all of the files that currently have
# a diff from upstrem.  Any arguments are passed just before the filenames.
# Very similar to nd.
ndu() {
  vim $@ $(git diff --name-only $(git rev-parse --abbrev-ref --symbolic-full-name @{u}))
}

export SKIM_DEFAULT_COMMAND="rg --files"
export SKIM_DEFAULT_OPTIONS="--reverse --height=7"
export PATH="${PATH}:${HOME}/.skim/bin"

export RIPGREP_CONFIG_PATH="${HOME}/dotfiles/ripgrep.rc"
