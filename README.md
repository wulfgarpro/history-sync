# history-sync
> An Oh My Zsh plugin for GPG encrypted, Internet synchronized Zsh history using Git.

## Installation
```bash
sudo apt install gpg git
git clone git@github.com:wulfgarpro/history-sync.git
cp -r history-sync ~/.oh-my-zsh/plugins
```

Then open .zshrc file and append history-sync to the plugin line:

```bash
plugins=(... history-sync)
```

And finally, reload zsh:

```bash
source ~/.zshrc
```

## Usage
Before history-sync can be useful, you need two things:

1. A hosted git repository, e.g. GitHub, Bitbucket
   * Ideally with ssh key access
2. A configured gpg key pair for encrypting and decrypting your history file
   * See [the GnuPG documentation](https://www.gnupg.org/documentation/) for more information

Once you have these things in place, it's just a matter of updating the needed environment variables to suit your configuration:

* ZSH_HISTORY_FILE: your zsh_history file location
* ZSH_HISTORY_PROJ: your git project for housing your zsh_history file
* ZSH_HISTORY_FILE_ENC: your encrypted zsh_history file location
* GIT_COMMIT_MSG: your default message when pushing to $ZSH_HISTORY_PROJ

Which have the following defaults:

```bash
ZSH_HISTORY_FILE_NAME=".zsh_history"
ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
ZSH_HISTORY_PROJ="${HOME}/.zsh_history_proj"
ZSH_HISTORY_FILE_ENC_NAME="zsh_history"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
GIT_COMMIT_MSG="latest $(date)"
```

and running the commands:

```bash
# pull history
zhpl

# push history
zhps -r "John Brown"

# pull and push history
zhsync
```

## Licence
MIT @ [James Fraser](https://www.wulfgar.pro)

