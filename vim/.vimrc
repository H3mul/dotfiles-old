if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif

call plug#begin('~/.vim/plugged')

" Theming
Plug 'itchyny/lightline.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'mhinz/vim-startify'

" Utility
Plug 'ciaranm/securemodelines'
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'RRethy/vim-illuminate'
Plug 'skywind3000/asyncrun.vim'
Plug 'eshion/vim-sync'
Plug 'airblade/vim-rooter'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'triglav/vim-visual-increment'
Plug 'tpope/vim-fugitive'
Plug 'heavenshell/vim-jsdoc'
Plug 'rhysd/git-messenger.vim'
Plug 'machakann/vim-highlightedyank'

" Syntax
Plug 'sheerun/vim-polyglot'

call plug#end()

set number
" set rnu
set cursorline
set wildmode=longest,list,full
set wildmenu

let g:secure_modelines_allowed_items = [
                \ "textwidth",   "tw",
                \ "softtabstop", "sts",
                \ "tabstop",     "ts",
                \ "shiftwidth",  "sw",
                \ "expandtab",   "et",   "noexpandtab", "noet",
                \ "filetype",    "ft",
                \ "foldmethod",  "fdm",
                \ "readonly",    "ro",   "noreadonly", "noro",
                \ "rightleft",   "rl",   "norightleft", "norl"
                \ ]

" turn off auto commenting
autocmd BufRead,BufNewFile * set formatoptions-=o

set mouse=a

" Window management
map  <F10>      <C-W>=
imap <F10>      <C-O><C-W>=
map  <F11>      <C-W>-
imap <F11>      <C-O><C-W>-
map  <F12>      <C-W>+
imap <F12>      <C-O><C-W>+
map  <C-F11>    :res 1<CR>
imap <C-F11>    <C-O>:res 1<CR>
map  <C-F12>    <C-W>_
imap <C-F12>    <C-O><C-W>_
map  <C-Up>     <C-W><Up>
imap <C-Up>     <C-O><C-W><Up>
map  <C-Down>   <C-W><Down>
imap <C-Down>   <C-O><C-W><Down>
map  <C-Left>   <C-W><Left>
imap <C-Left>   <C-O><C-W><Left>
map  <C-Right>  <C-W><Right>
imap <C-Right>  <C-O><C-W><Right>
map  <C-K>      <C-W><Up>
imap <C-K>      <C-O><C-W><Up>
map  <C-J>      <C-W><Down>
imap <C-J>      <C-O><C-W><Down>
map  <C-H>      <C-W><Left>
imap <C-H>      <C-O><C-W><Left>
map  <C-L>      <C-W><Right>
imap <C-L>      <C-O><C-W><Right>

" Toggle search highlighting
map <F5> :set hlsearch!<Bar>set hlsearch?<CR>
" highlight search by default
set hlsearch

" Toggle git gutter
map <F7> :GitGutterToggle<CR>

" Search
set incsearch
set ignorecase
set smartcase
set gdefault
" Go to match as they are found when typed
set incsearch

" Toggle paste
set pastetoggle=<F6>
map <F6> :set paste!<CR>i
imap <F6> <C-O>:set paste!<CR>

" Format json using python json.tool
map <F4> :%!python -m json.tool<CR>
imap <F4> <C-O>:%!python -m json.tool<CR>

" Turn on syntax highlighting if it's supported
if has('syntax') && &t_Co > 2
    syntax on
endif

if has('autocmd')
    filetype plugin indent on

" Jump to the last known cursor position when editing a file.
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" Change the indent amount for css and javascript files
    au FileType css set shiftwidth=2
    au FileType js set shiftwidth=4
endif

" vi mode - yuck!
set nocompatible

" Copy indent from current line when starting a new line
set autoindent
" Automatically indent new lines after certain characters
set smartindent
" Expand tabs into spaces
set expandtab
" Handle expanded tab spaces
set smarttab
" Use a 4 space tab
set shiftwidth=4
" Number of spaces a <Tab> is displayed as
set tabstop=8

" Make backspace work 'normally' in Insert mode
set backspace=indent,eol,start

" Show incomplete commands
set showcmd
" Parse files for vim line
set modeline

set background=dark
" Increase the command-line height to avoid hit-enter prompts
set cmdheight=2
" Always show the status line
set laststatus=2
" Change the default status line format
set statusline=%<%f%(\ %h%m%r%)%a%=%b\ 0x%B\ \ %l,%c%V\ %P

" list mode
set list
set listchars=tab:>-,precedes:<,extends:>
" String to put at the start of lines that have been wrapped
"set showbreak=>
" Don't display text as wrapped
set nowrap

" vim won't set the title of the terminal window unless $DISPLAY and $WINDOWID
" are set.  If bash's $PROMPT_COMMAND is set, then the title can be safely
" set.
if &term =~ "rxvt.*" || &term =~ "xterm.*"
    if exists("$PROMPT_COMMAND")
        set title
        set t_ts=]0;
    endif
endif


" Netrw Settings:

" set tree view
let g:netrw_liststyle = 3

" remove info banner
let g:netrw_banner = 0

set noequalalways

" Delete trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" tagbar shortcut
nmap <F9> :TagbarToggle<CR>
nmap <F8> :NERDTreeToggle<CR>

" Remove line at the bottom of screen
set cmdheight=1
set noshowmode

" NORD STUFF
let g:lightline = {'colorscheme': 'nord'}
colorscheme nord

set encoding=UTF-8

let g:nord_uniform_diff_background = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1

" Dont underline things in markdown
au FileType markdown setlocal nospell

" Dont show help on F1
map <F1> <nop>
imap <F1> <nop>

" Set ga to easy-align
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

" Typo central
command WQ wq
command Wq wq
command W w
command Q q

" w!! to write with sudo even if not opened with sudo
cmap w!! w !sudo tee >/dev/null %

" Execute currently edited script
autocmd Filetype python nnoremap <buffer> <leader>e :w<CR>:! python -u "%"<CR>

" Editor settings

set scrolloff=2
set hidden
set nojoinspaces

" Use clipboard all the time
set clipboard+=unnamedplus

set ttyfast
set lazyredraw

" Navigate wrapped lines
:nnoremap k gk
:nnoremap j gj


"##############################
" FZF preview floating window

let g:fzf_preview_window = 'right:50%'
let g:fzf_layout = { 'window': 'call Centered_floating_window()' }

if &termguicolors
    let g:preview_floating_window_winblend = 15
else
    let g:preview_floating_window_winblend = 0
endif

function! Centered_floating_window() abort
    let width = float2nr(&columns * 0.9)
    let height = float2nr(&lines * 0.9)
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = '╭' . repeat('─', width - 2) . '╮'
    let mid = '│' . repeat(' ', width - 2) . '│'
    let bot = '╰' . repeat('─', width - 2) . '╯'
    let lines = [top] + repeat([mid], height - 2) + [bot]

    let s:b_buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:b_buf, 0, -1, v:true, lines)
    call nvim_open_win(s:b_buf, v:true, opts)

    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    let s:f_buf = nvim_create_buf(v:false, v:true)
    call nvim_open_win(s:f_buf, v:true, opts)

    setlocal filetype=fzf
    setlocal nocursorcolumn
    execute 'set winblend=' . g:preview_floating_window_winblend

    augroup preview_floating_window
        " autocmd FileType fzf call s:set_fzf_last_query()
        autocmd WinLeave <buffer> silent! execute 'bdelete! ' . s:f_buf . ' ' . s:b_buf
    augroup END
endfunction

nmap <Leader>f [fzf-p]
xmap <Leader>f [fzf-p]

nmap <Leader>g [git]
xmap <Leader>g [git]

nnoremap <silent> [fzf-p]p     :<C-u>Files<CR>

nnoremap <silent> [git]s    :<C-u>GFiles?<CR>
nnoremap <silent> [git]c    :<C-u>GitMessenger<CR>
