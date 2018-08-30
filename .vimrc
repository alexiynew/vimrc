""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Init plugins
set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Plugins 
Plugin 'scrooloose/syntastic'
Plugin 'vim-scripts/a.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-bufferline'
Plugin 'bfrg/vim-cpp-modern'
Plugin 'airblade/vim-gitgutter'
Plugin 'embear/vim-localvimrc'

" Color
Plugin 'mkarmona/colorsbox'
Plugin 'morhetz/gruvbox'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Sets how many lines of history VIM has to remember
set history=700

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = "'"
let g:mapleader = "'"
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Show line numbers
set nu

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu
set wildmode=longest:full,full 

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Short messages
set shortmess=filnxtToOI

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch 

" How many tenths of a second to blink when matching brackets
set mat=2

" Show typed command
set showcmd

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" No margin to the left
set foldcolumn=0

" Mouse support
set mouse=a

" Copy\paste to OS
set clipboard+=unnamed
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Enable syntax highlighting
syntax enable 

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions=
    set guioptions+=a

    set guitablabel=%M\ %t
endif

if has('gui_running')
    set guifont=Ubuntu\ Mono\ Regular\ 13
endif

" Set terminal color mode
set t_Co=256
set background=dark

" Set colorscheme
colorscheme colorsbox-stnight

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Set whitespace chars
set listchars=tab:>-,eol:¬,space:·,trail:•
set list

" Foldmethod
set foldmethod=syntax
set foldlevelstart=99
set foldtext=CFoldText()

function! CFoldText()
    let lines_count = printf(" [ %d lines ]", v:foldend - v:foldstart + 1)
    return " + " . v:folddashes . lines_count
endfunction

" Save fold state
augroup AutoSaveFolds
     autocmd!
     autocmd BufWinLeave * silent! mkview
     autocmd BufWinEnter * silent! loadview
augroup END

" Special folding settings
autocmd BufReadPost,BufWinEnter .vimrc
            \ setlocal foldmethod=marker |
            \ setlocal foldlevelstart=0
" }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

nnoremap <esc><esc> :<C-u>nohlsearch<CR>

" Close all the buffers
map <leader>ba :%bd<cr>

map <C-tab> :b#<cr>

" Specify the behavior when switching between buffers 
try
  set switchbuf=useopen,usetab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Remember info about open buffers on close
set viminfo^=%
" }}}


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" {{{
" Always show the status line
set laststatus=2

" Format the status line
let g:git_status = ''

set statusline=\ \ %n:\ %f\ %y\ %m%r%h\ %w
set statusline+=%(%{GitStatus()}%)
set statusline+=%#warningmsg#%{SyntasticStatuslineFlag()}%*
set statusline+=%=%{&fileencoding?&fileencoding:&encoding}\ %-3.(%c%)%(%l/%L%)\ %(%P%)\ \  
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()

" Show hidden simbols 
nmap <leader>l :set list!<CR>

" Set working directory to currnt opened file
nmap <leader>cd :cd %:h<cr>
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Build mapping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
nmap <F5> make<cr>
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Autoreload settings
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC
augroup END
" }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Bufferline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let g:bufferline_echo = 1
" }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Enable checkers
let g:syntastic_cpp_checkers = ['cppcheck','gcc']

" Check header files
let g:syntastic_cpp_check_header = 1

" Headers path
let g:syntastic_cpp_include_dirs = ['.', './src']

" Disable the search of included header files 
let g:syntastic_cpp_no_include_search = 1

" Enable c17 support
let g:syntastic_cpp_compiler_options = '-std=c++17 -Wextra -Wall -Wno-unknown-pragmas'

" Default compiller
let g:syntastic_cpp_compiler = 'g++'

" Aggregates errors found by all checkers and displays them
let g:syntastic_aggregate_errors = 1

" Error and warning style
let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "!"
let g:syntastic_style_error_symbol = "✗"
let g:syntastic_style_warning_symbol = "!"

" Sttus lin format
let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
map <F3> :NERDTreeToggle<cr>
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Local vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
let g:localvimrc_sandbox = 0
let g:localvimrc_whitelist = ['/home/alex/Projects']
" }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" returns a string <branch/XX> where XX corresponds to the git status
" (for example "<master/ M>")
function! UpdateGitStatus()
    let gitoutput = split(system('git status --porcelain -b '.shellescape(expand('%')).' 2>/dev/null'),'\n')
    if len(gitoutput) > 0
        let b:git_status = '⎇ ' . ':' . strpart(get(gitoutput,0,''),3) . '[' . strpart(get(gitoutput,1,'  '),0,2) . ']'
    else
        let b:git_status = ''
    endif
endfunc

augroup git_status
    autocmd!
    autocmd BufEnter,BufWritePost * call UpdateGitStatus()
augroup END

function! GitStatus()
    if !exists('b:git_status')
        call UpdateGitStatus()
    endif

    return b:git_status
endf
" }}}
