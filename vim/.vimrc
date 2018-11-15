if empty(glob('~/.vim/autoload/plug.vim'))
	  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
	      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin()

" plugin manager
Plug 'junegunn/vim-plug'

" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" tree file view
Plug 'scrooloose/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'

" gutter git
Plug 'airblade/vim-gitgutter'

" seamless vim - tmux pane switching
Plug 'christoomey/vim-tmux-navigator'

" display buffers on top
Plug 'ap/vim-buftabline'

" surround elements
Plug 'tpope/vim-surround'

" onehalf color theme
"Plug 'sonph/onehalf', {'rtp': 'vim/'}

" themes
Plug 'NLKNguyen/papercolor-theme'
Plug 'rakr/vim-one'

Plug 'jceb/vim-orgmode'

call plug#end()


" ========
" SETTINGS

" open NERTTree
let NERDTreeShowHidden=1


" close nerttree if files are closed
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

highlight clear LineNr

" switch window buffers
let c = 1
while c <= 99
	execute "nnoremap " . c . "gb :" . c . "b\<CR>"	
	let c += 1
endwhile


" set linenumbers
set number
set rnu 


" turn off annoying asshole bell
set visualbell


" turn off auto commenting
autocmd BufRead,BufNewFile * set formatoptions-=o


" set search highlighting
set hls
" clear search
nnoremap <silent> <space> :noh<CR>


" NerdTree Settings
map <C-t> :NERDTreeToggle<CR>
let g:NERDTreeMapJumpPrevSibling=""
let g:NERDTreeMapJumpNextSibling=""


" <c-h> is interpreted as <bs> in neovim
" This is a bandaid fix until the team decides how
" they want to handle fixing it...(https://github.com/neovim/neovim/issues/2048)
nnoremap <silent> <bs> :TmuxNavigateLeft<cr>


" Fuzzy File Finder
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
nnoremap <c-p> :Files <CR>
nnoremap <c-P> :Files <CR>


" New line without insert
nnoremap o o<Esc>
nnoremap O O<Esc>


" COLORS
colorscheme PaperColor
set background=dark
