if empty(glob('~/.vim/autoload/plug.vim'))
	  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
	      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin()

" plugin manager
Plug 'junegunn/vim-plug'

Plug 'ciaranm/securemodelines'

Plug 'rafaqz/ranger.vim'

call plug#end()


" ========
" SETTINGS

" set number
" set rnu 
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
set ignorecase

" Window management
map <F10> <C-W>=
imap <F10> <C-O><C-W>=
map <F11> <C-W>-
imap <F11> <C-O><C-W>-
map <F12> <C-W>+
imap <F12> <C-O><C-W>+
map <C-F11> :res 1<CR>
imap <C-F11> <C-O>:res 1<CR>
map <C-F12> <C-W>_
imap <C-F12> <C-O><C-W>_
map <C-Up> <C-W><Up>
imap <C-Up> <C-O><C-W><Up>
map <C-Down> <C-W><Down>
imap <C-Down> <C-O><C-W><Down>
map <C-Left> <C-W><Left>
imap <C-Left> <C-O><C-W><Left>
map <C-Right> <C-W><Right>
imap <C-Right> <C-O><C-W><Right>
map <C-K> <C-W><Up>
imap <C-K> <C-O><C-W><Up>
map <C-J> <C-W><Down>
imap <C-J> <C-O><C-W><Down>
map <C-H> <C-W><Left>
imap <C-H> <C-O><C-W><Left>
map <C-L> <C-W><Right>
imap <C-L> <C-O><C-W><Right>

" Toggle search highlighting
map <F5> :set hlsearch!<Bar>set hlsearch?<CR>

" Toggle paste
set pastetoggle=<F6>
map <F6> :set paste!<CR>i
imap <F6> <C-O>:set paste!<CR>

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

" Turn off search highlighting
set nohlsearch
" Go to match as they are found when typed
set incsearch
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

" Select All
map <C-A> :norm ggVG<CR>

" Comment/uncomment
vmap ,c :s/^/#/<CR>
vmap ,u :s/^\(\s*\)#/\1/<CR>

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

set autochdir

set noequalalways

" ranger mappings
map <leader>rr :RangerEdit<cr>
map <leader>rv :RangerVSplit<cr>
map <leader>rs :RangerSplit<cr>
map <leader>rt :RangerTab<cr>
map <leader>ri :RangerInsert<cr>
map <leader>ra :RangerAppend<cr>
map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
map <leader>rd :RangerCD<cr>
map <leader>rld :RangerLCD<cr>

" auto trim whitespace

map  <C-T>      :%s/\s\+$//g<CR>
imap <C-T>      :%s/\s\+$//g<CR>
