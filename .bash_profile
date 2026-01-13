export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

eval "$(fzf --bash)"

# Enable SSH hostname autocompletion
if [ -f ~/.ssh-completion.bash ]; then
    . ~/.ssh-completion.bash
fi

export EDITOR=vi
export LC_ALL=C.UTF-8

. keychain --nolock --eval -q 

. /usr/share/bash-completion/completions/fzf
. /usr/share/doc/fzf/examples/key-bindings.bash

HISTCONTROL=ignoredups:erasedups:ignorespace

trap INT
trap HUP
trap TERM

if [ -z "$TMUX" ]; then
        unset LC_ALL
        tmux new -t default || tmux new -s default
fi

