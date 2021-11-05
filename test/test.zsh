#!/usr/bin/env bash

ACCESS_KEY=$1

function check_fn_exists() {
    typeset -f "$1" >/dev/null
    [[ $? -eq 0 ]] || {echo "FAILURE: Function '$1' missing"; exit $?}
}

function check_env_exists() {
    [[ -v $1 ]]
    [[ $? -eq 0 ]] || {echo "FAILURE: Environment variable '$1' missing"; exit $?}
}

function check_history() {
    grep "$1" ~/.zsh_history >> /dev/null
    [[ $? -eq 0 ]] || {echo {"FAILURE: History did not match '$1'"; exit $?}
}

# Basic setup for tests.
gpg --quick-gen-key --yes --batch --passphrase '' $UID
git config --global user.name "James Fraser"
git config --global user.email "wulfgar.pro@gmail.com"
git clone "https://$ACCESS_KEY@github.com/wulfgarpro/history-sync-test" ~/.zsh_history_proj
[[ -d ~/.zsh_history_proj ]]

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
check_env_exists ZSH_HISTORY_COMMIT_MSG
echo "SUCCESS"

echo "TEST SYNC HISTORY"
RAND=$RANDOM
echo "1 echo $RAND" >> ~/.zsh_history
echo "$UID" | zhps -y && zhpl -y
check_history "^1 echo $RAND$"
echo "SUCCESS"
