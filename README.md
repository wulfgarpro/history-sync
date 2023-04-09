[![history-sync](https://github.com/wulfgarpro/history-sync/actions/workflows/actions.yml/badge.svg)](https://github.com/wulfgarpro/history-sync/actions/workflows/actions.yml)

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
zsh
```

## Usage
Before history-sync can be useful, you need two things:

1. A hosted git repository, e.g. GitHub, Bitbucket
   * Ideally with ssh key access
2. A configured gpg key pair for encrypting and decrypting your history file and the enrolled public keys of all the nodes in your web of trust
   * See [the GnuPG documentation](https://www.gnupg.org/documentation/) for more information since it's outside the scope of this README

Once you have these things in place, it's just a matter of updating the needed environment variables to suit your configuration:

* ZSH_HISTORY_FILE: your zsh_history file location
* ZSH_HISTORY_PROJ: your git project for housing your zsh_history file
* ZSH_HISTORY_FILE_ENC: your encrypted zsh_history file location
* ZSH_HISTORY_COMMIT_MSG: your default message when pushing to $ZSH_HISTORY_PROJ

Which have the following defaults:

```bash
ZSH_HISTORY_FILE_NAME=".zsh_history"
ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
ZSH_HISTORY_PROJ="${HOME}/.zsh_history_proj"
ZSH_HISTORY_FILE_ENC_NAME="zsh_history"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
ZSH_HISTORY_COMMIT_MSG="latest $(date)"
```

and running the commands:

```bash
# pull history
zhpl

# push history
zhps -r "John Brown" -r 876T3F78 -r ...

# pull and push history
zhsync
```

## Notes for MacOS user

It is highly recommended that you replace MacOS' builtin `sed` and `awk` with GNU version of them.
The builtin software behaves slightly differently and creates weird compatability bugs


```bash
brew install gnu-sed
brew install gawk 
```

# then replace them with the built in version inside mac os by specifying in this in your bashrc, zshrc, etc. (basically your shell init configuration file)

```zsh
# in your .bashrc
# # gnu sed to replace macos sed
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"]
# # gnu awk to replace macos awk
PATH="/usr/local/opt/gawk/libexec/gnubin:$PATH"
```

```bash
# later, check if sed is from gnu version by 
which sed 

# or 
sed --version

# it should show you that sed is not /usr/bin/sed but /usr/local/opt/gnu-sed/libexec/gnubin/sed
# and the version argument will succeed (on mac os version, it will fail saying there is no such option)
```

## Demo
Check out the [screen cast](https://asciinema.org/a/43575).

## Licence
MIT @ [James Fraser](https://www.wulfgar.pro)
