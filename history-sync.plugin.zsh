ZSH_HISTORY_FILE=/home/james/.zsh_history
ZSH_HISTORY_PROJ=/home/james/.zsh_history_proj
ZSH_HISTORY_FILE_ENC=$ZSH_HISTORY_PROJ/zsh_history

cp -a /home/james/{.zsh_history,.zsh_history.bk}


function history-sync-pull() {
  # Pull down current history and merge
}

history-sync-push() {
    # Push current history to master

    # Encrypt file for push
    gpg -r "James Fraser" --encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE

    # Ask for confirm

    git commit -am $ZSH_HISTORY_PROJ && git push $ZSH_HISTORY_PROJ
}

alias zhpl=history-sync-pull
alias zhps=history-sync-push
