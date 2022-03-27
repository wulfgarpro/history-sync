#!/usr/bin/env zsh

function check_fn_exists() {
    typeset -f $1 >/dev/null
    [[ $? -eq 0 ]] || {echo "FAILURE: Function $1 missing"; exit $?}
}

function check_env_exists() {
    [[ -v $1 ]]
    [[ $? -eq 0 ]] || {echo "FAILURE: Environment variable $1 missing"; exit $?}
}

echo "TEST HISTORY-SYNC FUNCTIONS EXIST"
check_fn_exists _print_git_error_msg
check_fn_exists _print_gpg_encrypt_error_msg
check_fn_exists _print_gpg_decrypt_error_msg
check_fn_exists _usage
check_fn_exists history_sync_pull
check_fn_exists history_sync_push
echo "SUCCESS"

echo "TEST ENVIRONMENT VARIABLES EXIST"
check_env_exists ZSH_HISTORY_FILE
check_env_exists ZSH_HISTORY_PROJ
check_env_exists ZSH_HISTORY_FILE_ENC
check_env_exists GIT_COMMIT_MSG
echo "SUCCESS"

echo "TEST SYNC HISTORY"
git clone https://${{ secrets.ACCESS_KEY }}@github.com/wulfgarpro/history-sync-test ~/.zsh_history_proj
[[ -d ~/.zsh_history_proj ]]
echo "SUCCESS"
