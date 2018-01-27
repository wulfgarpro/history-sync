# ----------------------------------------------------------------
# Description
# -----------
# An Oh My Zsh plugin for GPG encrypted, Internet synchronized Zsh
# history using Git.
#
# ----------------------------------------------------------------
# Authors
# -------
#
# * James Fraser <wulfgar.pro@gmail.com>
#   https://www.wulfgar.pro
# ----------------------------------------------------------------
#
autoload -U colors && colors

alias zhpl=history_sync_pull
alias zhps=history_sync_push
alias zhsync="history_sync_pull && history_sync_push"

GIT=$(which git)
GPG=$(which gpg)

ZSH_HISTORY_PROJ="${HOME}/.zsh_history_proj"
ZSH_HISTORY_FILE_NAME=".zsh_history"
ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
ZSH_HISTORY_FILE_ENC_NAME="zsh_history"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
ZSH_HISTORY_FILE_DECRYPT_NAME="zsh_history_decrypted"
GIT_COMMIT_MSG="latest $(date)"

function _print_git_error_msg() {
    echo "$bold_color${fg[red]}There's a problem with git repository: ${ZSH_HISTORY_PROJ}.$reset_color"
    return
}

function _print_gpg_encrypt_error_msg() {
    echo "$bold_color${fg[red]}GPG failed to encrypt history file.$reset_color"
    return
}

function _print_gpg_decrypt_error_msg() {
    echo "$bold_color${fg[red]}GPG failed to decrypt history file.$reset_color"
    return
}

function _usage() {
    echo "$bold_color${fg[red]}Usage: $0 [-r <string> -r <string>...]$reset_color" 1>&2
    return
}

# Pull current master, decrypt, and merge with .zsh_history
function history_sync_pull() {
    DIR=$(pwd)

    # Backup
    cp -av "$ZSH_HISTORY_FILE" "$ZSH_HISTORY_FILE.backup" 1>&2
    
    # Pull
    cd "$ZSH_HISTORY_PROJ" && "$GIT" pull
    if [[ "$?" != 0 ]]; then
        _print_git_error_msg
        cd "$DIR"
        return
    fi
    
    # Decrypt
    "$GPG" --output "$ZSH_HISTORY_FILE_DECRYPT_NAME" --decrypt "$ZSH_HISTORY_FILE_ENC"
    if [[ "$?" != 0 ]]; then
        _print_gpg_decrypt_error_msg
        cd "$DIR"
        return
    fi
    
    # Merge
    cat "$ZSH_HISTORY_FILE" "$ZSH_HISTORY_FILE_DECRYPT_NAME" | awk '/:[0-9]/ { if(s) { print s } s=$0 } !/:[0-9]/ { s=s"\n"$0 } END { print s }' | sort -u > "$ZSH_HISTORY_FILE"
    rm  "$ZSH_HISTORY_FILE_DECRYPT_NAME"
    cd  "$DIR"
}

# Encrypt and push current history to master
function history_sync_push() {
    # Get option recipients
    local recipients=()
    while getopts -r: opt; do
        case "$opt" in
            r)
                recipients+="$OPTARG"
                ;;
            *)
                _usage
                return
                ;;
        esac
    done
    
    # Encrypt
    if ! [[ "${#recipients[@]}" > 0 ]]; then
        echo -n "Please enter GPG recipient name: "
        read name
        recipients+="$name"
    fi
    ENCRYPT_CMD="$GPG --yes -v "
    for r in "${recipients[@]}"; do
        ENCRYPT_CMD+="-r \"$r\" "
    done
    if [[ "$ENCRYPT_CMD" =~ '.(-r).+.' ]]; then
        ENCRYPT_CMD+="--encrypt --sign --armor --output $ZSH_HISTORY_FILE_ENC $ZSH_HISTORY_FILE"
        eval "$ENCRYPT_CMD"
        if [[ "$?" != 0 ]]; then
            _print_gpg_encrypt_error_msg
            return
        fi
    
        # Commit
        echo -n "$bold_color${fg[yellow]}Do you want to commit current local history file (y/N)?$reset_color "
        read commit
        if [[ -n "$commit" ]]; then
            case "$commit" in
                [Yy]* )
                    DIR=$(pwd)
                    cd "$ZSH_HISTORY_PROJ" && "$GIT" add * && "$GIT" commit -m "$GIT_COMMIT_MSG"
                    echo -n "$bold_color${fg[yellow]}Do you want to push to remote (y/N)?$reset_color "
                    read push
                    if [[ -n "$push" ]]; then
                        case "$push" in
                            [Yy]* )
                                "$GIT" push
                                if [[ "$?" != 0 ]]; then
                                    _print_git_error_msg
                                    cd "$DIR"
                                    return
                                fi
                                cd "$DIR"
                                ;;
                        esac
                    fi
                    if [[ "$?" != 0 ]]; then
                        _print_git_error_msg
                        cd "$DIR"
                        return
                    fi
                    ;;
                * )
                    ;;
            esac
        fi
    fi
}
