#!/usr/bin/env bash
# SSH Hostname Autocompletion Script
#
# This script provides intelligent SSH hostname autocompletion by parsing
# SSH configuration files and extracting Host entries.
#
# FEATURES:
# - Parses ~/.ssh/config and /etc/ssh/ssh_config
# - Deduplicates hostnames and maintains order
# - Filters out wildcard patterns (*, ?)
# - Handles malformed or empty config files gracefully
# - Easily extensible for custom config file locations
#
# INSTALLATION:
# 1. Copy this file to your home directory or another convenient location
# 2. Add the following line to your ~/.bashrc or ~/.bash_profile:
#    source ~/.ssh-completion.bash
# 3. Restart your shell or run: source ~/.bashrc
#
# USAGE:
# After installation, simply type 'ssh ' and press TAB to see available hostnames
# As you type, press TAB to autocomplete matching hostnames
#
# CUSTOMIZATION:
# To parse additional SSH config files, modify the SSH_CONFIG_FILES array below
#
# ASSUMPTIONS:
# - SSH config files follow standard OpenSSH format
# - Host directives are case-insensitive (Host, host, HOST)
# - One Host directive per line (no inline comments after hostnames)
#
# LIMITATIONS:
# - Does not expand wildcards or patterns in Host directives
# - Does not parse Match blocks or conditional configurations
# - Does not handle Include directives (OpenSSH 7.3+)

# Array of SSH config files to parse (in order of priority)
# Users can add custom config file paths here
declare -a SSH_CONFIG_FILES=(
    "$HOME/.ssh/config"
    "/etc/ssh/ssh_config"
)

# Function: _parse_ssh_config
# Description: Extracts and deduplicates hostnames from SSH configuration files
# Returns: Space-separated list of hostnames (via echo)
_parse_ssh_config() {
    local config_file
    local hostnames=()
    local seen_hosts=()
    
    # Iterate through all configured SSH config files
    for config_file in "${SSH_CONFIG_FILES[@]}"; do
        # Skip if file doesn't exist or isn't readable
        [[ ! -r "$config_file" ]] && continue
        
        # Parse the config file for Host directives
        # - Case-insensitive matching for 'Host' keyword
        # - Extract hostnames after 'Host' keyword
        # - Handle multiple hostnames per Host directive (space-separated)
        while IFS= read -r line; do
            # Match lines starting with 'Host' (case-insensitive)
            if [[ "$line" =~ ^[[:space:]]*[Hh][Oo][Ss][Tt][[:space:]]+(.+)$ ]]; then
                local host_entries="${BASH_REMATCH[1]}"
                
                # Split multiple hostnames on the same line
                # Disable glob expansion temporarily to prevent * and ? from expanding to filenames
                local -
                set -f
                for host in $host_entries; do
                    # Skip wildcard patterns (*, ?, brackets)
                    [[ "$host" == *[\*\?\[\]]* ]] && continue
                    
                    # Skip if hostname contains only wildcards or is empty
                    [[ -z "$host" ]] && continue
                    
                    # Deduplicate: only add if not seen before
                    local already_seen=0
                    for seen in "${seen_hosts[@]}"; do
                        if [[ "$seen" == "$host" ]]; then
                            already_seen=1
                            break
                        fi
                    done
                    
                    if [[ $already_seen -eq 0 ]]; then
                        seen_hosts+=("$host")
                        hostnames+=("$host")
                    fi
                done
            fi
        done < "$config_file"
    done
    
    # Return space-separated list of hostnames
    echo "${hostnames[@]}"
}

# Function: _ssh_hostname_completion
# Description: Bash completion function for SSH command
# This function is called by Bash's programmable completion system
_ssh_hostname_completion() {
    local cur prev opts
    
    # Get the current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Only provide hostname completion for the first argument after 'ssh'
    # or after certain flags that take hostnames as arguments
    case "$prev" in
        ssh|-l|-i|-F|-o|-p|-J)
            # For -l, -i, -F, -o, -p flags, don't provide hostname completion
            if [[ "$prev" != "ssh" ]]; then
                return 0
            fi
            ;;
    esac
    
    # Parse SSH config files and get hostnames
    opts=$(_parse_ssh_config)
    
    # Generate completions matching the current word
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    
    return 0
}

# Register the completion function for the 'ssh' command
# -F: Use the specified function for completion
# ssh: Apply completion to the 'ssh' command
complete -F _ssh_hostname_completion ssh

# Optional: Also enable completion for related commands
# Uncomment the following lines to enable completion for scp, sftp, etc.
# complete -F _ssh_hostname_completion scp
# complete -F _ssh_hostname_completion sftp
# complete -F _ssh_hostname_completion ssh-copy-id

# End of SSH Hostname Autocompletion Script
