set encoding=utf-8

call plug#begin('~/.config/nvim/plugged')

" Themes
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline-themes'

" Tools
Plug 'vim-airline/vim-airline'
Plug 'junegunn/vim-emoji'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdtree' " File explorer
Plug 'tpope/vim-commentary'
Plug '/usr/local/opt/fzf' " Fuzzy search
Plug 'junegunn/fzf.vim'
Plug 'wellle/targets.vim' " More useful text objects (e.g. function arguments)
Plug 'honza/vim-snippets'
Plug 'machakann/vim-highlightedyank'
Plug 'tpope/vim-fugitive' " Git helper
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'lyokha/vim-xkbswitch'

" Languages
Plug 'rust-lang/rust.vim'
Plug 'evanleck/vim-svelte'
Plug 'mattn/emmet-vim'
Plug 'jparise/vim-graphql'
Plug 'cespare/vim-toml'
Plug 'ollykel/v-vim'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'peitalin/vim-jsx-typescript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'chrisbra/csv.vim'
Plug 'vim-python/python-syntax'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'plasticboy/vim-markdown'
Plug 'editorconfig/editorconfig-vim'

" It is required to load devicons as last
Plug 'ryanoasis/vim-devicons'

call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Options

" Set color according to gnome-shell theme
if $XDG_CURRENT_DESKTOP == "GNOME" &&
  \ !(system('gsettings get org.gnome.desktop.interface gtk-theme') =~# "dark")
  set background=light
  let ayucolor='light'
else
  set background=dark
  let ayucolor='mirage'
  " let ayucolor='dark'
endif

colorscheme ayu
" colorscheme gruvbox

if colors_name == 'ayu'
  augroup alter_ayu_colorscheme
    autocmd!
    autocmd ColorScheme * highlight VertSplit guifg=#FFC44C
  augroup END
endif

let g:mapleader = " "


" Airline
let g:airline_theme = 'ayu_mirage'
" let g:airline_theme = 'gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#coc#enabled = 1


" Devicons
let g:webdevicons_enable_nerdtree = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 1


let g:closetag_xhtml_filetypes = 'xhtml,javascript.jsx,typescript.tsx'

let g:surround_{char2nr('r')} = "{'\r'}"

let g:python_highlight_all = 1

let g:AutoPairsFlyMode = 0

let g:XkbSwitchEnabled = 1
if $XDG_CURRENT_DESKTOP == "GNOME"
  let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
endif

syntax on
set hidden
set expandtab tabstop=4 softtabstop=2 shiftwidth=2
set autoindent
set list listchars=tab:➔\ ,trail:·
set ignorecase
set termguicolors
set cursorline colorcolumn=80,120
set mouse=a
set clipboard+=unnamedplus
set completeopt=menuone,longest
set incsearch nohlsearch
set ignorecase smartcase
set wildmenu wildmode=full
set signcolumn=yes " Additional column on left for emoji signs
set number relativenumber
set autoread autowrite autowriteall
set foldlevel=99 foldcolumn=1 foldmethod=syntax
set exrc secure " Project-local .nvimrc/.exrc configuration
set scrolloff=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocmd
function! s:RestoreCursor()
   if line("'\"") > 0 && line("'\"") <= line("$")
     exe "normal! g`\""
   endif
endfunction
autocmd BufReadPost * call s:RestoreCursor()

augroup auto_save
  autocmd!
  autocmd FocusLost * wa
augroup END

" Reload file if it changed on disk
autocmd BufEnter,FocusGained * checktime

" Helping nvim detect filetype
let s:additional_ftypes = {
  \ '*.zsh*': 'zsh',
  \ '.env.*': 'sh',
  \ '*.bnf': 'bnf',
  \ '*.webmanifest': 'json'
  \ }

augroup file_types
  autocmd!
  for kv in items(s:additional_ftypes)
    execute "autocmd BufNewFile,BufRead" kv[0] "setlocal filetype=" . kv[1]
  endfor

  " Tab configuration for different languages
  autocmd FileType go setlocal shiftwidth=4 softtabstop=4 noexpandtab

  " JSON5's comment
  autocmd FileType json syntax region Comment start="//" end="$"
  autocmd FileType json syntax region Comment start="/\*" end="\*/"
  autocmd FileType json setlocal commentstring=//\ %s
augroup END

" List of buf names where q does :q<CR>
let s:q_closes_windows = ['help', 'list']

augroup q_close
  for wname in s:q_closes_windows
    execute "autocmd FileType" wname "noremap <silent><buffer> q :q<CR>"
  endfor
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Line numbers configuration

" In filetypes below, the line numbers will be disabled
let s:disable_line_numbers = ['nerdtree', 'help', 'list']

function! s:SetNumber(set)
  if index(s:disable_line_numbers, &filetype) > -1
    return
  endif
  setlocal number
  if a:set
    setlocal relativenumber
  else
    setlocal norelativenumber
  endif
endfunction

autocmd Winenter,FocusGained * call s:SetNumber(1)
autocmd Winleave,FocusLost * call s:SetNumber(0)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings

" The block below WON'T execute in vscode-vim extension,
" so thath's why I use it
if has('nvim')
  nnoremap j gj
  nnoremap k gk
  nnoremap gj j
  nnoremap gk k
endif

inoremap ii <Esc>
vnoremap ii <Esc>

" Arrow movement mappings
nnoremap <Down> <C-E>
nnoremap <Up> <C-Y>
nnoremap <S-Up> <C-U>M
nnoremap <S-Down> <C-D>M
nnoremap <C-Up> <C-B>M
nnoremap <C-Down> <C-F>M

noremap <C-P> :Files<CR>

nnoremap <silent> <C-_> :Commentary<CR>
vnoremap <silent> <C-_> :Commentary<CR>gv
inoremap <silent> <C-_> <C-O>:Commentary<CR>

" Indenting
nnoremap > >>
nnoremap < <<
vnoremap > >gv
vnoremap < <gv

nnoremap <silent> <M-]> :bnext<CR>
nnoremap <silent> <M-[> :bprevious<CR>
nnoremap <silent> <Leader>src :w<CR> :source ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>cfg :e ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>h :set hlsearch!<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buffer operations
function! s:DelBuf(del_all)
  if (a:del_all)
    bprevious | split | bnext | bufdo bdelete
  else
    bprevious | split | bnext | bdelete
  endif
endfunction
nnoremap <silent> <Leader>d :call <SID>DelBuf(0)<CR>
nnoremap <silent> <Leader>ad :call <SID>DelBuf(1)<CR>

nnoremap <silent> <M-k> :m-2<CR>
nnoremap <silent> <M-j> :m+1<CR>
vnoremap <silent> <M-k> :m'<-2<CR>gv
vnoremap <silent> <M-j> :m'>+1<CR>gv

" Prettier bindings
function! s:RunPrettier()
  execute "silent !prettier --write %"
  edit
endfunction
nnoremap <silent> <Leader>pretty :call <SID>RunPrettier()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc configuration
let g:coc_global_extensions = [
  \ 'coc-emmet',
  \ 'coc-snippets',
  \ 'coc-svelte',
  \ 'coc-explorer',
  \ ]

highlight link CocWarningHighlight None

function! s:CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~ '\s'
endfunction

function! s:ExpandCompletion() abort
  if !pumvisible()
    return coc#refresh()
  endif
  " if s:check_back_space()
  "   return "\<Tab>"
  " else
  "   return coc#refresh()
  " endif
endfunction

function! s:SelectCompletion() abort
  if pumvisible()
    return coc#_select_confirm()
  else
    return "\<C-G>u\<CR>"
  endif
endfunction

function! s:CocTab()
  return pumvisible() ? "\<C-N>" : "\<Tab>"
endfunction

function! s:CocShiftTab()
  return pumvisible() ? "\<C-P>" : "\<Tab>"
endfunction

" COC actions & completion helpers
inoremap <silent><expr> <Tab> <SID>CocTab()
inoremap <silent><expr> <S-Tab> <SID>CocShiftTab()
inoremap <silent><expr> <C-Space> <SID>ExpandCompletion()
inoremap <silent><expr> <CR> <SID>SelectCompletion()
nnoremap <silent> <CR> :call CocAction("doHover")<CR>
nnoremap <silent> <F2> :call CocAction("rename")<CR>
nnoremap <silent> <Leader>f :call CocAction("format")<CR>
nnoremap <silent> <C-LeftMouse> :call CocAction("jumpDefinition")<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc commands & functions

" Adds shebang to current file and makes it executable (to current user)
let s:filetype_executables = { 'javascript': 'node' }

function! s:Shebang()
  update
  execute "silent !chmod u+x %"

  if stridx(getline(1), "#!") == 0
    echo "Shebang already exists."
    return
  endif
  execute "silent !which" &filetype
  if v:shell_error == 0
    let shb = "#!/usr/bin/env " . &filetype
  elseif has_key(s:filetype_executables, &filetype)
    let shb = "#!/usr/bin/env " . s:filetype_executables[&filetype]
  else
    echoerr "Filename not supported."
    return
  endif
  call append(0, shb)
  edit
endfunction
command! -nargs=0 Shebang call s:Shebang()

function! Durka()
  let themes = map(
    \ split(system("ls ~/.config/nvim/colors/")) +
    \ split(system("ls /usr/share/nvim/runtime/colors/")),
    \ "v:val[:-5]"
    \)
  for th in themes
    echo th
    execute "colorscheme" th
    sleep 200m
  endfor
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Case-tools

" shake_case -> camelCase
nmap <silent> <Leader>cc viw<Leader>cc
vnoremap <silent> <Leader>cc :s/\%V_\(.\)/\U\1/g<CR>

" snake_case -> PascalCase
nmap <silent> <Leader>pc viw<Leader>pc
vmap <silent> <Leader>pc <Leader>cc`<vU

" camelCase/PascalCase -> snake_case
nmap <silent> <Leader>sc viw<Leader>sc
vnoremap <silent> <Leader>sc :s/\%V\(\l\)\(\u\)/\1_\l\2/g<CR>`<vu

" snake_case -> kebab-case
" TODO: implement

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc-explorer configuration (obsolette for now)
" function! s:open_coc_explorer()
"   if &filetype == 'coc-explorer'
"     CocCommand explorer
"   else
"     CocCommand explorer --no-toggle
"   endif
" endfunction
" noremap <silent> <F3> :call <SID>open_coc_explorer()<CR>
" noremap <silent> <S-F3> :call <SID>open_coc_explorer()<CR>

" function! s:auto_open_explorer()
"   if exists("s:std_in")
"     return
"   endif

"   if argc() == 0
"     CocCommand explorer
"   elseif argc() == 1 && isdirectory(argv()[0])
"     execute "CocCommand explorer" argv()[0]
"   endif
" endfunction

" function! s:close_cocexplorer_alone()
"   if winnr("$") == 1 && &filetype == 'coc-explorer'
"     q
"   endif
" endfunction

" autocmd StdinReadPre * let s:std_in = 1
" autocmd VimEnter * call s:auto_open_explorer()
" autocmd BufEnter * call s:close_cocexplorer_alone()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree configuration
let NERDTreeCascadeSingleChildDir = 0
let NERDTreeMouseMode = 2
let NERDTreeShowLineNumbers = 0
let NERDTreeMinimalUI = 1

function! s:ToggleNERDTree(shift)
  if (a:shift && g:NERDTree.IsOpen()) || &filetype == 'nerdtree'
    NERDTreeClose
  elseif a:shift
    NERDTreeFind
  else
    NERDTreeCWD
  endif
endfunction

" function! s:NERDTreeCwd()
"   if &filetype == "nerdtree"

" endfunction

function! s:AutoOpenNERDTree()
  if argc() == 0 && !exists("s:std_in")
    NERDTree
  elseif argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in")
    wincmd p
    enew
    exe "NERDTree" argv()[0]
  endif
endfunction

function! s:CloseNERDTreeAlone()
  if winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()
    quit
  endif
endfunction

nnoremap <silent> <F3> :call <SID>ToggleNERDTree(0)<CR>
nnoremap <silent> <Leader><F3> :call <SID>ToggleNERDTree(1)<CR>

autocmd StdinReadPre * let s:std_in = 1
" autocmd VimEnter * call s:AutoOpenNERDTree()
autocmd BufEnter * call s:CloseNERDTreeAlone()
