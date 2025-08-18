[![history-sync](https://github.com/wulfgarpro/history-sync/actions/workflows/actions.yml/badge.svg)](https://github.com/wulfgarpro/history-sync/actions/workflows/actions.yml)

# history-sync

> An Oh My Zsh plugin for GPG encrypted, Internet synchronized Zsh history using Git.

## Installation

```bash
sudo apt install gpg git
git clone git@github.com:wulfgarpro/history-sync.git
cp -r history-sync ~/.oh-my-zsh/plugins
```

Open `.zshrc` file and add `history-sync` to the plugins list:

```bash
plugins=(... history-sync)
```

The reaload Zsh:

```bash
exec zsh
```

## Usage

Before using `history-sync`, ensure you have:

1. A hosted Git repository, e.g. GitHub, Bitbucket, with SSH key access.
2. A configured GPG key pair for encrypting/decrypting your history file, and the public keys of all
   nodes in your web-of-trust.
   * See [the GnuPG documentation](https://www.gnupg.org/documentation/) for details.

Once set up, configure the following environment variables:

* `ZSH_HISTORY_FILE`: your `zsh_history` file location
* `ZSH_HISTORY_PROJ`: Git project for storing `zsh_history`
* `ZSH_HISTORY_FILE_ENC`: encrypted history file location
* `ZSH_HISTORY_COMMIT_MSG`: default commit message when pushing
* `ZSH_HISTORY_DEFAULT_RECIPIENT`: default recipient for `zhps`

Defaults:

```bash
ZSH_HISTORY_FILE_NAME=".zsh_history"
ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
ZSH_HISTORY_PROJ="${HOME}/.zsh_history_proj"
ZSH_HISTORY_FILE_ENC_NAME="zsh_history"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
ZSH_HISTORY_COMMIT_MSG="latest $(date)"
ZSH_HISTORY_DEFAULT_RECIPIENT=""
```

Optional:

* `ZSH_HISTORY_GIT_REMOTE`: if set, the plugin clones the remote repo on first use

## Commands

```bash
# Pull history
zhpl

# Push history
zhps -r "John Brown" -r 876T3F78 -r ...

# Or set a default recipient to omit -r:
# ZSH_HISTORY_DEFAULT_RECIPIENT="John Brown"

# Pull + push history
zhsync
```

## Demo

Check out the [screen cast](https://asciinema.org/a/43575).

## Licence

MIT @ [James Fraser](https://www.wulfgar.pro)
