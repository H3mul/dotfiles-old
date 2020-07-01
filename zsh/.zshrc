source ~/.zsh_aliases
if [[ -f ~/.zsh_local ]]; then
    source ~/.zsh_local
fi

zsh_plugin_home=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/
zsh_plugin () {
    if [[ -z $1 ]]; then; return; fi;
    # eg wfxr/forgit
    plugin_path=$1
    plugin=${plugin_path#*\/}
    plugin_home="$zsh_plugin_home/$plugin"

    if [ ! -d  "$plugin_home" ]; then
        echo "[+] installing $plugin for zsh..."
        git clone "https://github.com/$plugin_path" "$plugin_home"
    fi
}

zsh_plugin 'wfxr/forgit'
zsh_plugin 'zsh-users/zsh-syntax-highlighting'
zsh_plugin 'zsh-users/zsh-autosuggestions'

unset zsh_plugin

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

ZSH_THEME="hemul"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  fzf
  systemd
  sudo
  zsh-autosuggestions
  # z
  zsh-syntax-highlighting
  vi-mode
  forgit
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'

# No beeps
unsetopt beep
#xset b off
#xset b 0 0 0

setopt no_share_history

################################
# Keyboard Setup

# vi mode prompt
bindkey -v
export KEYTIMEOUT=1

bindkey '^[l' forward-word
bindkey '^[h' backward-word
bindkey '^[L' end-of-line
bindkey '^[H' beginning-of-line
bindkey '^?' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# From
# https://wiki.archlinux.org/index.php/Zsh#Key_bindings

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-line
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-line
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start {
        echoti smkx
    }
    function zle_application_mode_stop {
        echoti rmkx
    }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

bindkey '^[k' up-line-or-beginning-search
bindkey '^[j' down-line-or-beginning-search

bindkey '^S' sudo-command-line

################################

# user-wide npm install
PATH="$HOME/.node/bin:$PATH"
export NODE_PATH="$HOME/.node/lib/node_modules"
export NPM_CONFIG_PREFIX="$HOME/.node"

# add scripts to path
PATH="$HOME/scripts:$PATH"

set -o ignoreeof

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

export FZF_DEFAULT_OPTS='
--color fg:252,hl:67,fg+:252,bg+:235,hl+:81
--color info:144,prompt:161,spinner:135,pointer:135,marker:118'

export FZF_DEFAULT_COMMAND='rg --files --hidden'
