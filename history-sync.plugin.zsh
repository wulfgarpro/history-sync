ZSH_HISTORY_FILE=$HOME/.zsh_history
ZSH_HISTORY_PROJ=$HOME/.zsh_history_proj
ZSH_HISTORY_FILE_ENC=$ZSH_HISTORY_PROJ/zsh_history

# backup; how about rotate?
cp -a $HOME/{.zsh_history,.zsh_history.bk}


# Pull down current history and merge; how to merge?
function history-sync-pull() {
}

# Push current history to master
history-sync-push() {
  # Encrypt history file for push
  gpg -r "James Fraser" --encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE

  # Ask for confirm before pushing remote
  git commit -am $ZSH_HISTORY_PROJ && git push $ZSH_HISTORY_PROJ
}

# Simple function aliases
alias hpl=history-sync-pull
alias hps=history-sync-push
