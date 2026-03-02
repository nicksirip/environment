# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

# Environment
export EDITOR=vi
export LC_ALL=C.UTF-8

# History
HISTCONTROL=ignoredups:erasedups:ignorespace

# Interactive-only settings
if [[ $- == *i* ]]; then

# Signal traps
trap INT
trap HUP
trap TERM

# Completions
if [ -f ~/.brew-completion.bash ]; then
    . ~/.brew-completion.bash
fi

if [ -f ~/.ssh-completion.bash ]; then
    . ~/.ssh-completion.bash
fi

if [ -f ~/.podman-completion.bash ]; then
    . ~/.podman-completion.bash
fi

if [ -f /usr/share/bash-completion/completions/fzf ]; then
    . /usr/share/bash-completion/completions/fzf
fi

if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash
fi

# Tools
if [ -f /usr/share/bash-completion/completions/fzf ]; then
    eval "$(fzf --bash)"
fi

if command -v keychain &>/dev/null; then
    eval "$(keychain --nolock --eval -q)"
fi

if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Session
if [ -z "$TMUX" ]; then
    unset LC_ALL
    tmux new -t default || tmux new -s default
fi

fi # end interactive-only settings

