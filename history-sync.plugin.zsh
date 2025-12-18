# ----------------------------------------------------------------
# Description
# ----------------------------------------------------------------
# An Oh My Zsh plugin for GPG encrypted, Internet synchronized Zsh
# history using Git.
#
# ----------------------------------------------------------------
# James Fraser <wulfgar.pro@gmail.com> - https://www.wulfgar.pro
# ----------------------------------------------------------------

autoload -U colors && colors

alias zhpl=history_sync_pull
alias zhps=history_sync_push
alias zhsync="history_sync_pull && history_sync_push"

CP() { command cp "$@"; }
MV() { command mv "$@"; }
RM() { command rm "$@"; }
TR() { LC_ALL=C command tr "$@"; }
AWK() { command awk "$@"; }
CAT() { command cat "$@"; }
GIT() { command git "$@"; }
GPG() { command gpg "$@"; }
SED() { command sed "$@"; }
DATE() { command date "$@"; }
FOLD() { command fold "$@"; }
GREP() { command grep "$@"; }
HEAD() { command head "$@"; }
PERL() { command perl "$@"; }
SORT() { LC_ALL=C command sort "$@"; }
MKTEMP() { command mktemp "$@"; }

ZSH_HISTORY_PROJ="${ZSH_HISTORY_PROJ:-${HOME}/.zsh_history_proj}"
ZSH_HISTORY_FILE_NAME="${ZSH_HISTORY_FILE_NAME:-.zsh_history}"
ZSH_HISTORY_FILE="${ZSH_HISTORY_FILE:-${HOME}/${ZSH_HISTORY_FILE_NAME}}"
ZSH_HISTORY_FILE_ENC_NAME="${ZSH_HISTORY_FILE_ENC_NAME:-zsh_history}"
ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_FILE_ENC:-${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}}"
ZSH_HISTORY_FILE_DECRYPT_NAME="${ZSH_HISTORY_FILE_DECRYPT_NAME:-zsh_history_decrypted}"
ZSH_HISTORY_FILE_MERGED_NAME="${ZSH_HISTORY_FILE_MERGED_NAME:-zsh_history_merged}"
ZSH_HISTORY_COMMIT_MSG="${ZSH_HISTORY_COMMIT_MSG:-latest $(DATE)}"
ZSH_HISTORY_DEFAULT_RECIPIENT="${ZSH_HISTORY_DEFAULT_RECIPIENT:-}"

_print_git_error_msg() {
    echo "$bold_color${fg[red]}There's a problem with git repository: ${ZSH_HISTORY_PROJ}.$reset_color"
    return
}

_print_gpg_encrypt_error_msg() {
    echo "$bold_color${fg[red]}GPG failed to encrypt history file.$reset_color"
    return
}

_print_gpg_decrypt_error_msg() {
    echo "$bold_color${fg[red]}GPG failed to decrypt history file.$reset_color"
    return
}

_usage() {
    echo "Usage: [ [-r <string> ...] [-y] ]" 1>&2
    echo
    echo "Optional args:"
    echo
    echo "      -r recipients"
    echo "      -s signers"
    echo "      -y force"
    return
}

# "Squash" each multi-line command in the passed history files to one line
_squash_multiline_commands_in_files() {
    # Create temporary files
    # Use global variables to use same path's in the restore-multi-line commands
    # function
    TMP_FILE_1=$(mktemp)
    TMP_FILE_2=$(mktemp)

    # Generate random character sequences to replace \n and anchor the first
    # line of a command (use global variable for new-line-replacement to use it
    # in the restore-multi-line commands function)
    NL_REPLACEMENT=$(TR -dc 'a-zA-Z0-9' < /dev/urandom |
        FOLD -w 32 | HEAD -n 1)
    local FIRST_LINE_ANCHOR=$(TR -dc 'a-zA-Z0-9' < /dev/urandom |
        FOLD -w 32 | HEAD -n 1)

    for i in "$ZSH_HISTORY_FILE" "$ZSH_HISTORY_FILE_DECRYPT_NAME"; do
        # Filter out multi-line commands and save them to a separate file
        GREP -v -B 1 '^: [0-9]\{1,10\}:[0-9]\+;' "${i}" |
            GREP -v -e '^--$' > "${TMP_FILE_1}"

        # Filter out multi-line commands and remove them from the original file
        GREP -v -x -F -f "${TMP_FILE_1}" "${i}" > "${TMP_FILE_2}" \
            && MV "${TMP_FILE_2}" "${i}"

        # Add anchor before the first line of each command
        SED "s/\(^: [0-9]\{1,10\}:[0-9]\+;\)/${FIRST_LINE_ANCHOR} \1/" \
            "${TMP_FILE_1}" > "${TMP_FILE_2}" \
            && MV "${TMP_FILE_2}" "${TMP_FILE_1}"

        # Replace all \n with a sequence of symbols
        if [[ "$(SED --version 2>&1)"  == *"GNU"* ]]; then
          SED ':a;N;$!ba;s/\n/'" ${NL_REPLACEMENT} "'/g' \
              "${TMP_FILE_1}" > "${TMP_FILE_2}"
        else
          # Assume BSD `sed`
          PERL -0777 -pe 's/\n/'" ${NL_REPLACEMENT} "'/g' \
            "${TMP_FILE_1}" > "${TMP_FILE_2}"
        fi
        MV "${TMP_FILE_2}" "${TMP_FILE_1}"

        # Replace first line anchor by \n
        SED "s/${FIRST_LINE_ANCHOR} \(: [0-9]\{1,10\}:[0-9]\+;\)/\n\1/g" \
            "${TMP_FILE_1}" > "${TMP_FILE_2}" \
            && MV "${TMP_FILE_2}" "${TMP_FILE_1}"

        # Merge squashed multiline commands to the history file
        CAT "${TMP_FILE_1}" >> "${i}"

        # Sort history file
        SORT -n < "${i}" > "${TMP_FILE_1}" && MV "${TMP_FILE_1}" "${i}"
    done
}

# Restore multi-line commands in the history file
_restore_multiline_commands_in_file() {
    # Filter unnecessary lines from the history file (Binary file ... matches)
    # and save them in a separate file
    GREP -v '^: [0-9]\{1,10\}:[0-9]\+;' "$ZSH_HISTORY_FILE" > "${TMP_FILE_1}"

    # Filter out unnecessary lines and remove them from the original file
    GREP -v -x -F -f "${TMP_FILE_1}" "$ZSH_HISTORY_FILE" > "${TMP_FILE_2}" && \
        MV "${TMP_FILE_2}" "$ZSH_HISTORY_FILE"

    # Replace the sequence of symbols by \n to restore multi-line commands
    SED "s/ ${NL_REPLACEMENT} /\n/g" "$ZSH_HISTORY_FILE" > "${TMP_FILE_1}" \
        && MV "${TMP_FILE_1}" "$ZSH_HISTORY_FILE"

    # Unset global variables
    unset NL_REPLACEMENT TMP_FILE_1 TMP_FILE_2
}

# Pull current master, decrypt, and merge with .zsh_history
history_sync_pull() {
    # Get options force
    local force=false
    while getopts y opt; do
        case "$opt" in
            y)
                force=true
                ;;
        esac
    done
    DIR=$(pwd)

    # Backup
    if [[ $force = false ]]; then
        CP -av "$ZSH_HISTORY_FILE" "$ZSH_HISTORY_FILE.backup" 1>&2
    fi


    # Clone if not exist
    if [[ ! -d "$ZSH_HISTORY_PROJ" ]]; then
        if [[ ! -v ZSH_HISTORY_GIT_REMOTE ]]; then
            _print_git_error_msg
            return
        fi

        "$GIT" clone "$ZSH_HISTORY_GIT_REMOTE" "$ZSH_HISTORY_PROJ"
        if [[ "$?" != 0 ]]; then
            _print_git_error_msg
            return
        fi
    fi

    # Pull
    cd "$ZSH_HISTORY_PROJ" && GIT pull
    if [[ "$?" != 0 ]]; then
        _print_git_error_msg
        cd "$DIR"
        return
    fi

    # Decrypt
    GPG --output "$ZSH_HISTORY_FILE_DECRYPT_NAME" --decrypt "$ZSH_HISTORY_FILE_ENC"
    if [[ "$?" != 0 ]]; then
        _print_gpg_decrypt_error_msg
        cd "$DIR"
        return
    fi

    # Check if EXTENDED_HISTORY is enabled, and if so, "squash" each multi-line
    # command in local and decrypted history files to one line
    [[ -o extendedhistory ]] && _squash_multiline_commands_in_files

    # Merge
    CAT "$ZSH_HISTORY_FILE" "$ZSH_HISTORY_FILE_DECRYPT_NAME" | \
      AWK '/:[0-9]/ { if(s) { print s } s=$0 } !/:[0-9]/ { s=s"\n"$0 } END { print s }' | \
      SORT -u > "$ZSH_HISTORY_FILE_MERGED_NAME"
    MV "$ZSH_HISTORY_FILE_MERGED_NAME" "$ZSH_HISTORY_FILE"
    RM  "$ZSH_HISTORY_FILE_DECRYPT_NAME"
    cd  "$DIR"

    # Check if EXTENDED_HISTORY is enabled, and if so, restore multi-line
    # commands in the local history file
    [[ -o extendedhistory ]] && _restore_multiline_commands_in_file
    # Strip trailing '\' if the next line is blank
    SED -E -i '/\\$/ { N; s/\\+\n$/\n/ }' "$ZSH_HISTORY_FILE"
    # Strip blank lines
    SED -i '/^$/d' "$ZSH_HISTORY_FILE"
}

# Encrypt and push current history to master
history_sync_push() {
    # Get options recipients, force
    local recipients=()
    local signers=()
    local force=false
    while getopts r:s:y opt; do
        case "$opt" in
            r)
                recipients+=("$OPTARG")
                ;;
            s)
                signers+=("$OPTARG")
                ;;
            y)
                force=true
                ;;
            *)
                _usage
                return
                ;;
        esac
    done

    # Encrypt
    if ! [[ "${#recipients[@]}" > 0 ]]; then
        if [[ -n "$ZSH_HISTORY_DEFAULT_RECIPIENT" ]]; then
            recipients+=("$ZSH_HISTORY_DEFAULT_RECIPIENT")
        else
            echo -n "Please enter GPG recipient name: "
            read name
            recipients+=("$name")
        fi
    fi

    GPG_ENCRYPT_CMD_OPT="--yes -v "
    for r in "${recipients[@]}"; do
        GPG_ENCRYPT_CMD_OPT+="-r \"$r\" "
    done
    if [[ "${#signers[@]}" > 0 ]]; then
        GPG_ENCRYPT_CMD_OPT+="--sign "
        for s in "${signers[@]}"; do
            GPG_ENCRYPT_CMD_OPT+="--default-key \"$s\" "
        done
    fi

    if [[ "$GPG_ENCRYPT_CMD_OPT" != *"--sign"* ]]; then
        if [[ $force = false ]]; then
            echo -n "$bold_color${fg[yellow]}Do you want to sign with first key found in secret keyring (y/N)?$reset_color "
            read sign
        else
            sign='y'
        fi

        case "$sign" in
            [Yy]* )
                    GPG_ENCRYPT_CMD_OPT+="--sign "
                    ;;
                * )
                    ;;
        esac
    fi

    if [[ "$GPG_ENCRYPT_CMD_OPT" =~ '.(-r).+.' ]]; then
        GPG_ENCRYPT_CMD_OPT+="--encrypt --armor --output \"$ZSH_HISTORY_FILE_ENC\" \"$ZSH_HISTORY_FILE\""
        eval GPG "$GPG_ENCRYPT_CMD_OPT"
        if [[ "$?" != 0 ]]; then
            _print_gpg_encrypt_error_msg
            return
        fi

        # Commit
        if [[ $force = false ]]; then
            echo -n "$bold_color${fg[yellow]}Do you want to commit current local history file (y/N)?$reset_color "
            read commit
        else
            commit='y'
        fi

        if [[ -n "$commit" ]]; then
            case "$commit" in
                [Yy]* )
                    DIR=$(pwd)
                    cd "$ZSH_HISTORY_PROJ" && GIT add * && GIT commit -m "$ZSH_HISTORY_COMMIT_MSG"
                    local local_status=$?

                    if [[ $force = false ]]; then
                        echo -n "$bold_color${fg[yellow]}Do you want to push to remote (y/N)?$reset_color "
                        read push
                    else
                        push='y'
                    fi

                    if [[ -n "$push" ]]; then
                        case "$push" in
                            [Yy]* )
                                GIT push
                                local_status=$?
                                ;;
                        esac
                    fi

                    cd "$DIR"
                    if [[ "$local_status" != 0 ]]; then
                        _print_git_error_msg
                        return
                    fi
                    ;;
                * )
                    ;;
            esac
        fi
    fi
}
