set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let $NVIM_HOME=expand("$HOME/.config/nvim")

runtime plugins.vim
runtime fzf-floating-window.vim
runtime settings.vim
runtime keybinds.vim
