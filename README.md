# environment
This is my MBP setup.

## SSH Hostname Autocompletion

This repository includes an intelligent SSH hostname autocompletion feature that extracts hostnames from your SSH configuration files and enables tab completion in Bash.

### Features

- **Automatic hostname extraction**: Parses `~/.ssh/config` and `/etc/ssh/ssh_config` to find all configured hosts
- **Intelligent filtering**: Automatically filters out wildcard patterns (*, ?, [])
- **Deduplication**: Ensures each hostname appears only once in completion suggestions
- **Robust error handling**: Gracefully handles missing, empty, or malformed config files
- **Easy customization**: Easily extend to parse additional config file locations

### Installation

The SSH autocompletion is automatically enabled when you source the `.bash_profile`:

```bash
source ~/.bash_profile
```

Or manually source the completion script:

```bash
source ~/.ssh-completion.bash
```

### Usage

Once installed, simply type `ssh` followed by a space and press `TAB` to see all available hostnames:

```bash
ssh <TAB>
# Shows: host1 host2 host3 ...

ssh web<TAB>
# Autocompletes to: ssh webserver
```

### Customization

To parse additional SSH config files, edit `.ssh-completion.bash` and modify the `SSH_CONFIG_FILES` array:

```bash
declare -a SSH_CONFIG_FILES=(
    "$HOME/.ssh/config"
    "/etc/ssh/ssh_config"
    "$HOME/.ssh/custom_config"  # Add your custom config here
)
```

You can also enable autocompletion for related SSH commands by uncommenting these lines in `.ssh-completion.bash`:

```bash
complete -F _ssh_hostname_completion scp
complete -F _ssh_hostname_completion sftp
complete -F _ssh_hostname_completion ssh-copy-id
```

### How It Works

The completion script:
1. Parses SSH config files for `Host` directives (case-insensitive)
2. Extracts hostname entries, filtering out wildcards and patterns
3. Deduplicates hostnames while maintaining order of appearance
4. Integrates with Bash's programmable completion system via `complete` and `compgen`

### Limitations

- Does not expand wildcards or patterns in Host directives
- Does not parse Match blocks or conditional configurations
- Does not follow Include directives (OpenSSH 7.3+)

### Example SSH Config

```
# ~/.ssh/config
Host webserver
    HostName web.example.com
    User admin

Host db-prod
    HostName db.prod.example.com
    User root

Host dev-*
    HostName dev.example.com
    # This wildcard entry won't appear in completions
```

With this config, typing `ssh <TAB>` will suggest: `webserver` and `db-prod` (but not `dev-*`).
