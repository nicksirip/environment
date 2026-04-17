#!/usr/bin/env bash
# install.sh
#
# Installs the dotfiles in this repository by creating symlinks in $HOME.
# Existing files are backed up with a .bak suffix before being replaced.
#
# USAGE:
#   ./install.sh
#
# Safe to run multiple times (idempotent).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DOTFILES=(
    .bash_profile
    .brew-completion.bash
    .ssh-completion.bash
    .podman-completion.bash
    .tmux.conf
)

echo "Installing dotfiles from: $REPO_DIR"
echo

for file in "${DOTFILES[@]}"; do
    src="$REPO_DIR/$file"
    dst="$HOME/$file"

    if [[ ! -f "$src" ]]; then
        echo "  SKIP   $file (source not found)"
        continue
    fi

    # Back up an existing file that is not already a symlink to our source.
    # Append a timestamp so repeated runs never overwrite a previous backup.
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        echo "  BACKUP $dst -> ${backup}"
        mv "$dst" "$backup"
    fi

    # Remove a stale symlink (wrong target) so we can create a fresh one
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" != "$src" ]]; then
        rm "$dst"
    fi

    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
        echo "  OK     $file (already linked)"
    else
        ln -s "$src" "$dst"
        echo "  LINK   $dst -> $src"
    fi
done

echo
echo "Done. Restart your shell or run: source ~/.bash_profile"
