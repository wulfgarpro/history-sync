#!/usr/bin/env zsh

ACCESS_KEY=$1

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
git clone "https://$ACCESS_KEY@github.com/wulfgarpro/history-sync-test" ~/.zsh_history_proj
[[ -d ~/.zsh_history_proj ]]
gpg --quick-gen-key --yes --batch --passphrase '' $UID
echo "1 cd ~" >> ~/.zsh_history
gpg -r $UID -e ~/.zsh_history
cd ~/.zsh_history_proj
mv ~/.zsh_history.gpg .
git -c user.name='James Fraser' -c user.email='wulfgar.pro@gmail.com' commit -am "Added encrypted history"
git push "https://$ACCESS_KEY@github.com/wulfgarpro/history-sync-test"
echo "SUCCESS"
