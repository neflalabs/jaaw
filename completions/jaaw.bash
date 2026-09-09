# Bash completion for jaaw

_jaaw_get_aliases() {
    local alias_file="${XDG_CONFIG_HOME:-$HOME/.config}/jaaw/aliases.tsv"
    if [ -f "$alias_file" ]; then
        awk -F'\t' '$1 !~ /^#/ && NF {print $1}' "$alias_file" 2>/dev/null
    fi
}

_jaaw_completions() {
    local cur prev subcmds opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    subcmds="alias devices exec shell scrcpy use init update"
    opts="-w --wizard -p --pair -c --connect -s --screen -b --bitrate --screen-off --off --scrcpy-args -u --usb -m --manual -l --list -d --diag -r --reset -t --timeout -U --update -v --version -h --help"

    case "$prev" in
        -t|--timeout)
            mapfile -t COMPREPLY < <(compgen -W "10 30 60 120" -- "$cur")
            return 0
            ;;
        -b|--bitrate)
            mapfile -t COMPREPLY < <(compgen -W "1M 2M 4M 6M 8M 12M 16M" -- "$cur")
            return 0
            ;;
        --scrcpy-args)
            return 0
            ;;
        init)
            mapfile -t COMPREPLY < <(compgen -W "bash zsh fish" -- "$cur")
            return 0
            ;;
        alias)
            mapfile -t COMPREPLY < <(compgen -W "set list rm get" -- "$cur")
            return 0
            ;;
        shell|scrcpy|use|exec)
            local aliases
            aliases=$(_jaaw_get_aliases)
            mapfile -t COMPREPLY < <(compgen -W "$aliases" -- "$cur")
            return 0
            ;;
    esac

    if [ "$COMP_CWORD" -ge 2 ]; then
        local first="${COMP_WORDS[1]}"
        if [ "$first" = "alias" ]; then
            case "$prev" in
                rm|del|delete|get)
                    local aliases
                    aliases=$(_jaaw_get_aliases)
                    mapfile -t COMPREPLY < <(compgen -W "$aliases" -- "$cur")
                    return 0
                    ;;
            esac
        fi
    fi

    if [[ "$cur" == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
        return 0
    else
        mapfile -t COMPREPLY < <(compgen -W "$subcmds $opts" -- "$cur")
        return 0
    fi
}

complete -F _jaaw_completions jaaw

