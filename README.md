# dotfiles
Personal Configurations of Various Programs

## Getting Started
This generally assumes that nvim and git are installed.

If you haven't installed rust, then go ahead an do:

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

```

Then you can run the following from the git repository:
```
cargo run
nvim +PlugInstall

```


Also, make sure to add in the tmux plugin manager
([tpm](https://github.com/tmux-plugins/tpm))
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
