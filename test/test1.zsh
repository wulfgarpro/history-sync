#!/usr/bin/env zsh

function check_fn_exists() {
    typeset -f $1 >/dev/null
    [[ $? -eq 0 ]] || (echo "Function $1 missing"; exit $?)
}

echo "Test history-sync functions exist"
check_fn_exists _print_git_error_msg
check_fn_exists _print_gpg_encrypt_error_msg
check_fn_exists _print_gpg_decrypt_error_msg
check_fn_exists _usage
check_fn_exists history_sync_pull
check_fn_exists history_sync_push
echo "Success"
