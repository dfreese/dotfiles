# dotfiles
Personal Configurations of Various Programs

## Background
Install NeoVim, typically:
```shell
sudo apt-get install neovim
```

Generate a ssh key for github or similar, based on [github's article](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```shell
ssh-keygen -t ed25519 -C "youremail@example.com" -f ~/.ssh/github -N ""
```
* `-t ed25519`: generate a key of type ed25519 (as recommended by github)
* `-C "youremail@example.com"`: sets the comment in the public key to the email associated with the key
* `-f ~/.ssh/github`: creates a ~/.ssh/github and ~/.ssh/github.pub key/public key pair
* `-N ""`: sets an empty passphrase.  Not necessarily recommended, as ssh-agent can [store passphrases](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/working-with-ssh-key-passphrases)

## Getting Started
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
