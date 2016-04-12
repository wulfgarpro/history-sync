### A oh-my-zsh plugin for internet synced zsh_history

Design
------

1. command shortcut to sync current `history-sync {get,set}`, `hisync get, set`
2. don't re-sync if no new changes
3. some way of encrypting contents / transmission
  3.1. pgp crypt hist file
    3.1.1. this means generating pgp key option if missing from system
    3.2.1. OR use a symmetric key
  3.2. git push to exising or new repo (master)
  3.2. overwrite existing history file at repo
4. configurable,
  4.1. setup hist file repo
    4.1.1. can use existing repo
  4.2. backup current history locally before re-sync (automatic)
    4.2.1. re-instate back option `hisync --backup --revert`
  4.3. work with current $HISTFILE or specified file `hisync --file /path/to/file`

