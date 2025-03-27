# dotfiles

Run `setup.sh` from anywhere.  It will target `$HOME` by default and backup
where this repository is cloned with `.bak` appended.

## Assorted Notes

Generate a ssh key for github or similar, based on [github's article](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```shell
ssh-keygen -t ed25519 -C "youremail@example.com" -f ~/.ssh/github -N ""
```
* `-t ed25519`: generate a key of type ed25519 (as recommended by github)
* `-C "youremail@example.com"`: sets the comment in the public key to the email associated with the key
* `-f ~/.ssh/github`: creates a ~/.ssh/github and ~/.ssh/github.pub key/public key pair
* `-N ""`: sets an empty passphrase.  Not necessarily recommended, as ssh-agent can [store passphrases](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/working-with-ssh-key-passphrases)
