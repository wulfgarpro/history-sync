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
    read -p "Please enter GPG recipient name: " name
    NAME=name

    # Encrypt history file for push
    gpg -r $NAME --encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE

    while true; do
        read -p "Do you want to commit and push current local history file?" yn
        case $yn in
            [Yy]* ) 
                git commit -am $ZSH_HISTORY_PROJ && git push $ZSH_HISTORY_PROJ; break;;
            [Nn]* )
                exit;;
            * )
                exit;;
        esac
    done
}

# Simple function aliases
alias hpl=history-sync-pull
alias hps=history-sync-push
