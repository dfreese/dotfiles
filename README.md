# dotfiles
Personal Configurations of Various Programs

## Getting Started
This generally assumes that vim and git are installed.  After installing the dotfiles,
to install Vundle:

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
pushd $PWD; cd ~/.vim/bundle/YouCompleteMe && python install.py --clang-completer; popd

```
