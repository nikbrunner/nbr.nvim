
filetype plugin on

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  AUTOcmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
    " appearence
    Plug 'christianchiarulli/nvcode-color-schemes.vim'
    Plug 'cormacrelf/vim-colors-github'
    Plug 'lewis6991/github_dark.nvim'
    Plug 'metalelf0/jellybeans-nvim'
    Plug 'rktjmp/lush.nvim'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'ryanoasis/vim-devicons'

    " file management
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzy-native.nvim'
    Plug 'airblade/vim-rooter'
    Plug 'mbbill/undotree'

    " general workflow 
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-obsession'
    Plug 'tpope/vim-surround'
    Plug 'chaoren/vim-wordmotion'
    Plug 'djoshea/vim-autoread'
    Plug 'machakann/vim-highlightedyank'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    Plug 'vifm/vifm.vim'
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'reedes/vim-pencil'
    Plug 'mhinz/vim-startify'
    Plug 'karb94/neoscroll.nvim'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install'  }
    Plug 'mileszs/ack.vim'
    Plug 'mattn/emmet-vim'
    Plug 'MattesGroeger/vim-bookmarks'
    Plug 'numtostr/FTerm.nvim'
    Plug 'gennaro-tedesco/nvim-peekup'

    " tab & lines
    Plug 'mkitt/tabline.vim'
    Plug 'gcmt/taboo.vim'
    Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
 
    " LSP
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Syntax
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " git
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    Plug 'kdheepak/lazygit.nvim'

    " language
    Plug 'pangloss/vim-javascript'    " JavaScript support
    Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
    Plug 'HerringtonDarkholme/yats.vim'

    " formater
    Plug 'prettier/vim-prettier', { 'do': 'npm install' }

 call plug#end()
