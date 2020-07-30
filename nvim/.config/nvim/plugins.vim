if empty(glob("$NVIM_HOME/autoload/plug.vim"))
    silent !curl -fLo $NVIM_HOME/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $NVIM_HOME/init.vim
endif

call plug#begin(expand("$NVIM_HOME/plugged"))

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
Plug 'rhysd/conflict-marker.vim'
Plug 'vimlab/split-term.vim'
Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vim-zettel'
Plug 'alvan/vim-closetag'
Plug 'jiangmiao/auto-pairs'
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-sleuth'

" Syntax
Plug 'sheerun/vim-polyglot'

call plug#end()
