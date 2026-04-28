# ===== Zsh Configuration =====
# Minimalist config for Arch/Hyprland aesthetic

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias lsi='kitten icat'
alias gzw-update='chmod 644 ~/.local/share/Steam/steamapps/common/Gray\ Zone\ Warfare/GZW/Content/SKALLA/PrebuildWorldData/World/cache/*.dat && echo "¡Archivos de GZW desbloqueados! Ya puedes actualizar en Steam."'

# Smart cat: glow for markdown, bat for everything else
cat() {
    for file in "$@"; do
        if [[ "$file" == *.md || "$file" == *.markdown ]]; then
            glow "$file"
        else
            bat --paging=never "$file"
        fi
    done
}

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship prompt
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

fpath+=~/.zfunc; autoload -Uz compinit; compinit
