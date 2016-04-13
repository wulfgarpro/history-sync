ZSH_HISTORY_FILE=$HOME/.zsh_history
ZSH_HISTORY_PROJ=$HOME/.zsh_history_proj
ZSH_HISTORY_FILE_ENC=$ZSH_HISTORY_PROJ/zsh_history

# backup; how about rotate?
cp -a $HOME/{.zsh_history,.zsh_history.backup}


# Pull down current history and merge; how to merge?
function history-sync-pull() {
}

# Push current history to master
history-sync-push() {
  echo -n "Please enter GPG recipient name: "
  read name && NAME=name

  if [[ -n $FILE ]]; then
    echo "gpg'ing zsh history file: $ZSH_HISTORY_FILE"
    # Encrypt history file for push
    gpg -v -r $NAME --encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE
  fi

  echo -n "Do you want to commit and push current local history file? "
  read commit
    
  if [[ -n $commit ]]; then
    case $commit in
      [Yy]* ) 
        git commit -am $ZSH_HISTORY_PROJ && git push $ZSH_HISTORY_PROJ; 
        if [[ $? == 1 ]] echo "$fg_bold[red] Fix your git repo..." fi
        break;;
      [Nn]* )
        exit;;
      * )
        exit;;
    esac
  fi
}

# Simple function aliases
alias hpl=history-sync-pull
alias hps=history-sync-push

