###
# James Fraser
# <wulfgar.pro@gmail.com>
###

autoload -U colors
colors

ZSH_HISTORY_FILE=$HOME/.zsh_history
ZSH_HISTORY_PROJ=$HOME/.zsh_history_proj
ZSH_HISTORY_FILE_ENC=$ZSH_HISTORY_PROJ/zsh_history
GIT_COMMIT_MSG="latest $(date)"

# Pull down current history and merge; how to merge?
function history-sync-pull() {
  # Backup; how about rotate? better way?
  cp -a $HOME/{.zsh_history,.zsh_history.backup}
  cd $ZSH_HISTORY_PROJ && git pull
  # Decrypt
  gpg --output zsh_history_decrypted --decrypt zsh_history
  
  # Merge
  cat $HOME/.zsh_history zsh_history_decrypted | sort -u > $HOME/.zsh_history 
  rm zsh_history_decrypted
}

# Push current history to master
function history-sync-push() {
  echo -n "Please enter GPG recipient name: "
  read name

  if [[ -n $name ]]; then
    gpg -v -r $NAME --encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE

    # Failed gpg
    if [[ $? != 0 ]]; then
      echo "$bold_color$fg[red]GPG failed to encrypt history file... exiting.${reset_color}"; return 
    fi

    echo -n "$bold_color$fg[yellow]Do you want to commit/push current local history file? ${reset_color}"
    read commit    
    if [[ -n $commit ]]; then
      case $commit in
        [Yy]* ) 
          cd $ZSH_HISTORY_PROJ && git commit -am $GIT_COMMIT_MSG && git push
          if [[ $? -ne 0 ]]; then 
            echo "$bold_color$fg[red]Fix your git repo...${reset_color}"; return
          fi
          ;;
        [Nn]* )
          ;;
        * )
          ;;
      esac          
    fi
  fi
}

# Function aliases
alias zhpl=history-sync-pull
alias zhps=history-sync-push
alias zhsync="history-sync-pull && history-sync-push"

