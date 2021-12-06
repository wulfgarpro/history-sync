#!/usr/bin/env zsh

set -e

# Test history-sync functions exist
typeset -f _print_git_error_msg 2>/dev/null
typeset -f _print_gpg_encrypt_error_msg 2>/dev/null
typeset -f _print_gpg_decrypt_error_msg 2>/dev/null
typeset -f _usage 2>/dev/null
typeset -f history_sync_pull 2>/dev/null
typeset -f history_sync_push 2>/dev/null
