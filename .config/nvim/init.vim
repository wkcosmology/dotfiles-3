set termguicolors
set background=dark

lua init = require 'init'
lua init.setup()
autocmd VimEnter lua init.setup_later()

" Must be AFTER augroups above
syntax on

let g:mapleader = ' '

let g:surround_{char2nr('r')} = "{'\r'}"
let g:surround_{char2nr('j')} = "{/* \r */}"
let g:surround_{char2nr('c')} = "/* \r */"

let g:AutoPairsFlyMode = 0
let g:AutoPairsMultilineClose = 0

let g:XkbSwitchEnabled = 1
if $XDG_CURRENT_DESKTOP == 'GNOME'
  let g:XkbSwitchLib = '/usr/local/lib/libg3kbswitch.so'
endif

let g:vim_indent_cont = 0

"---------------------------------- Options -----------------------------------"
set hidden
set expandtab softtabstop=4 tabstop=4 shiftwidth=2
set autoindent smartindent
set list listchars=tab:⇥\ ,trail:·,space:·
set ignorecase
set cursorline colorcolumn=80,120
set mouse=a
set clipboard+=unnamedplus
set completeopt=menu,menuone,noselect
set incsearch nohlsearch
set ignorecase smartcase
set wildmenu wildmode=full
set signcolumn=yes
set autoread autowrite autowriteall

set foldlevel=99 foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldopen=hor,mark,percent,quickfix,search,tag,undo
" set foldcolumn=1 " Enable additional column w/ visual folds

set exrc secure " Project-local .nvimrc/.exrc configuration
set scrolloff=3
set diffopt+=vertical
" Vim-like block cursor
" set guicursor=n-v-c-i-ci:block,o:hor50,r-cr:hor30,sm:block
set splitbelow splitright
set regexpengine=0
set lazyredraw
set guifont=JetBrains\ Mono\ Nerd\ Font:h18
" set shada='1000,%
set noshowmode
set shortmess+=c
set undofile

"---------------------------------- Autocmd -----------------------------------"
augroup ft_indent
  autocmd!
  autocmd FileType go,make setlocal shiftwidth=4 softtabstop=4 noexpandtab
  autocmd FileType python,java,csharp
                 \ setlocal sw=4 sts=4 et
  autocmd FileType javascript,typescript,javascriptreact,typescriptreact,svelte,vim
                 \ setlocal sw=2 sts=2 et
  autocmd FileType lua setlocal sw=2 sts=2 et
augroup END

function! s:RestoreCursor()
  echom 'Restoring cursor'
  let l:last_pos = line("'\"")
  if l:last_pos > 0 && l:last_pos <= line('$')
    exe 'normal! g`"'
  endif
endfunction
augroup restore_cursor
  autocmd!
  autocmd BufReadPost * call s:RestoreCursor()
augroup END

augroup auto_save
  autocmd!
  autocmd FocusLost * silent! wall
augroup END

" Reload file if it changed on disk
augroup auchecktime
  autocmd!
  autocmd BufEnter,FocusGained * silent! checktime
augroup END

" Helping nvim detect filetype
let s:additional_filetypes = {
\   'zsh': '*.zsh*',
\   'sh': '.env.*',
\   'bnf': '*.bnf',
\   'json': '*.webmanifest',
\   'rest': '*.http',
\   'elixir': ['*.exs', '*.ex'],
\ }

augroup file_types
  autocmd!
  for kv in items(s:additional_filetypes)
    if type(kv[1]) == v:t_list
      for ext in kv[1]
        execute 'autocmd BufNewFile,BufRead ' . ext
              \ . ' setlocal filetype=' . kv[0]
      endfor
    else
      execute 'autocmd BufNewFile,BufRead ' . kv[1]
            \ . ' setlocal filetype=' . kv[0]
    endif
  endfor

  autocmd FileType markdown setlocal conceallevel=2

  " json 5 comment
  autocmd FileType json
                 \ syntax region Comment start="//" end="$" |
                 \ syntax region Comment start="/\*" end="\*/" |
                 \ setlocal commentstring=//\ %s
augroup END

" Filetypes names where q does :q<CR>
let g:q_close_ft = ['help', 'list', 'fugitive']
let g:esc_close_ft = ['NvimTree']
let g:disable_line_numbers = [
\   'nerdtree', 'NvimTree', 'help',
\   'list', 'clap_input', 'TelescopePrompt',
\ ]

augroup aux_win_close
  autocmd!
  autocmd FileType fugitive nmap <buffer> <Esc> gq
  for ft in g:esc_close_ft
    execute 'autocmd FileType ' . ft . ' noremap <silent><buffer> <Esc> :q<CR>'
  endfor
  for ft in g:q_close_ft
    execute 'autocmd FileType ' . ft . ' noremap <silent><buffer> q :q<CR>'
  endfor
augroup END

augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua init.yank_highlight()
augroup END

"------------------------- Line numbers configuration -------------------------"
function! s:SetNumber(set)
  if empty(&filetype) || index(g:disable_line_numbers, &filetype) > -1
    return
  endif
  setlocal number
  if a:set
    setlocal relativenumber
  else
    setlocal norelativenumber
  endif
endfunction

augroup line_numbers
  autocmd!
  autocmd BufEnter,Winenter,FocusGained * call s:SetNumber(1)
  autocmd BufLeave,Winleave,FocusLost * call s:SetNumber(0)
augroup END

"----------------------------- Mapping functions ------------------------------"
function RevStr(str)
  let l:chars = split(submatch(0), '\zs')
  return join(reverse(l:chars), '')
endfunction

function! s:CompTab()
  if exists('*neosnippet#jumpable') && neosnippet#jumpable()
    return "\<Plug>(neosnippet_jump)"
  elseif pumvisible()
    return "\<C-N>"
  else
    return "\<Tab>"
  endif
endfunction

function! s:CompSTab()
  if pumvisible()
    return "\<C-P>"
  else
    return "\<S-Tab>"
  endif
endfunction

function! s:CompCR()
  if pumvisible() && complete_info()['selected'] != -1
    return compe#confirm()
  else
    return "\<CR>"
  endif
endfunction

function! s:nvimTreeToggle(find)
  if &filetype == 'NvimTree'
    NvimTreeClose
  elseif a:find
    NvimTreeFindFile
  else
    NvimTreeOpen
    let l:found = win_findbuf(bufnr('NvimTree'))
    if len(l:found)
      call win_gotoid(l:found[0])
    endif
  endif
endfunction

"----------------------------- Buffer operations ------------------------------"
function! s:buf_filt(inc_cur)
  function! s:filt_fn(include_current, idx, val)
    if !bufexists(a:val) ||
     \ !buflisted(a:val) ||
     \ buffer_name(a:val) =~? 'NERD_tree_*' ||
     \ (a:include_current && bufnr() == a:val)
      return v:false
    endif
    return v:true
  endfunction
  return filter(range(1, bufnr('$')), function('s:filt_fn', [a:inc_cur]))
endfunction

function! s:DellAllBuf()
  wall
  silent execute 'bdelete ' . join(s:buf_filt(0))
endfunction

function! s:DellThisBuf()
  update
  bprevious | split | bnext | bdelete
endfunction

" Delete buffers except current
function! s:DelAllExcept()
  wall
  silent execute 'bdelete' join(s:buf_filt(1))
endfunction

" TODO
function! s:DelToLeft()
  silent execute 'bdelete' join(range(1, bufnr() - 1))
endfunction

augroup formatprgs
  autocmd!
  autocmd FileType haskell setlocal formatprg=brittany
  autocmd FileType typescript,typescriptreact
                 \ setlocal formatprg=prettier\ --parser\ typescript
  autocmd FileType javascript,javascriptreact
                 \ setlocal formatprg=prettier\ --parser\ babel
  autocmd FileType cabal setlocal formatprg=cabal-fmt
  autocmd FileType lua setlocal formatprg=lua-format\ -c\ ~/.lua-format
augroup END

augroup completion_nvim
  autocmd!
  autocmd BufEnter * lua init.attach_completion()
augroup END

augroup lsp_diagnostics
  autocmd!
  autocmd CursorMoved * lua init.show_lsp_diagnostics()
augroup END

"----------------------------- Embedded terminal ------------------------------"
augroup terminal_insert
  autocmd!
  autocmd TermOpen * startinsert
augroup END

"------------------------- Misc commands & functions --------------------------"
" Adds shebang to current file and makes it executable (to current user)
let s:filetype_executables = {'javascript': 'node'}

function! s:shebang()
  silent! write
  execute 'silent !chmod u+x %'
  if stridx(getline(1), "#!") == 0
    echo 'Shebang already exists.'
    return
  endif
  execute 'silent !which ' . &filetype
  let l:shb = '#!/usr/bin/env '
  if v:shell_error == 0
    let l:shb .= &filetype
  elseif has_key(s:filetype_executables, &filetype)
    let l:shb .= s:filetype_executables[&filetype]
  else
    echoerr 'Filename not supported.'
    return
  endif
  call append(0, shb)
  update
endfunction

command! -nargs=0 Shebang call s:shebang()

function! Durka()
  let themes = map(
  \   split(system("ls ~/.config/nvim/colors/")) +
  \   split(system("ls /usr/share/nvim/runtime/colors/")),
  \   "v:val[:-5]"
  \ )
  for th in themes
    echo th
    execute 'colorscheme' th
    sleep 200m
  endfor
endfunction

function! PrettyComment(comment, fill_char) abort
  let l:text_len = strlen(getline('.'))
  let l:remain_len = 80 - l:text_len

  let l:l_size = l:remain_len / 2
  let l:r_size = l:remain_len - l:l_size

  let l:result = a:comment .
    \ repeat(a:fill_char, l:l_size - strlen(a:comment) - 1) .
    \ ' ' .
    \ getline('.') .
    \ ' ' .
    \ repeat(a:fill_char, l:r_size - 1)

  call setline('.', l:result)
endfunction

function! Emoji2Unicode() abort
  let l:c = execute('ascii')
  let l:u = substitute(l:c, '[^x]*Hex\s*\([a-f0-9]*\),[^H]*', '\1', 'g')
  let l:u = repeat('0', strlen(l:u) % 4) . l:u
  let @m = substitute(l:u, '\(.\{4\}\)', '\\u\1', 'g')
  execute "normal xi\<C-R>m\<Esc>"
endfunction

command! -nargs=0 Prettier lua init.run_prettier()

command! -nargs=0 RestartLsp lua init.restart_lsp()
command! -nargs=0 LspLog execute 'edit ' . luaeval('vim.lsp.get_log_path()')

"------------------------- Comment tool configuration -------------------------"
function! s:VComment()
  return mode() ==# 'v' ? 'Scgv' : ":Commentary\<CR>gv"
endfunction
autocmd FileType typescriptreact setlocal commentstring=//\ %s

augroup LSP_highlight
  autocmd!
  autocmd CursorHold <buffer> silent! lua vim.lsp.buf.document_highlight()
  autocmd CursorHoldI <buffer> silent! lua vim.lsp.buf.document_highlight()
  " autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
augroup END

function! PasteBlock()
  execute 'normal!' repeat("O\<Esc>", len(split(@", '\n')))
  normal! p
endfunction

"------------------------------- Neovide stuff --------------------------------"
let g:neovide_fullscreen=v:true

"--------------------------------- Mappings -----------------------------------"
" The block below WON'T execute in vscode-vim extension,
" so thath's why I use it
if has('nvim')
  nnoremap j gj
  nnoremap k gk
  nnoremap gj j
  nnoremap gk k
endif

" Arrow movement mappings
nnoremap <Down> <C-E>
nnoremap <Up> <C-Y>
nnoremap <S-Up> <C-U>M
nnoremap <S-Down> <C-D>M
nnoremap <C-Up> <C-B>M
nnoremap <C-Down> <C-F>M

" Indenting
vnoremap > >gv
vnoremap < <gv

" Buffer nav
nnoremap <silent> <M-]> :bnext<CR>
nnoremap <silent> <M-[> :bprevious<CR>
nnoremap <silent> <Leader>d :call <SID>DellThisBuf()<CR>
nnoremap <silent> <Leader>ad :call <SID>DellAllBuf()<CR>
nnoremap <silent> <Leader>od :call <SID>DelAllExcept()<CR>
nnoremap <silent> <Leader>ld :call <SID>DelToLeft()<CR>

" Tab nav
nnoremap <silent> th :tabprevious<CR>
nnoremap <silent> tj :tablast<CR>
nnoremap <silent> tk :tabfirst<CR>
nnoremap <silent> tl :tabnext<CR>
nnoremap <silent> tt :tabnew<CR>
nnoremap <silent> td :tabclose<CR>
nnoremap <silent> tH :-tabmove<CR>
nnoremap <silent> tL :+tabmove<CR>

nnoremap <silent> <Leader>src :w<CR> :source ~/.config/nvim/init.vim<CR>
nnoremap <silent> <Leader>cfg 
                  \ :e ~/.config/nvim/lua/init.lua <Bar>
                  \ :e ~/.config/nvim/init.vim <CR>
nnoremap <silent> <Leader>hs :setlocal hlsearch!<CR>
nnoremap <silent> <Leader>w :wall<CR>

" LSP mappings:
inoremap <expr> <Tab> <SID>CompTab()
inoremap <expr> <S-Tab> <SID>CompSTab()
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR> <SID>CompCR()
nnoremap <silent> <Leader>f :lua init.format_code()<CR>
nnoremap <silent> <Leader>ah :lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <Leader>aj :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <Leader>ae
       \ :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nnoremap <silent> <Leader>aa :lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <F2> :lua vim.lsp.buf.rename()<CR>

vnoremap <Leader>rev :s/\%V.\+\%V./\=RevStr(submatch(0))<CR>gv
nnoremap <Leader>eu :call Emoji2Unicode()<CR>

" Case-conversion tools
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

nnoremap <silent> <M-k> :m-2<CR>
nnoremap <silent> <M-j> :m+1<CR>
vnoremap <silent> <M-k> :m'<-2<CR>gv
vnoremap <silent> <M-j> :m'>+1<CR>gv

vnoremap <Leader>rv :s/\%V

nnoremap <Leader>o o<Esc>
nnoremap <Leader><S-O> O<Esc>

nnoremap <Leader>` :10split <Bar> :terminal<CR>

" Commenting
nnoremap <silent> <C-_> :Commentary<CR>
inoremap <silent> <C-_> <C-O>:Commentary<CR>
xmap <expr><silent> <C-_> <SID>VComment()

" File explorer
nnoremap <silent> <F3> :call <SID>nvimTreeToggle(0)<CR>
nnoremap <silent> <Leader><F3> :call <SID>nvimTreeToggle(1)<CR>

" Search tool
nnoremap <silent> <C-P> :Telescope find_files<CR>
nnoremap <silent> <Leader>rg :Telescope live_grep<CR>
nnoremap <silent> <Leader>b :Telescope buffers<CR>
nnoremap <silent> <C-B> :Telescope buffers<CR>

" Git
nnoremap <silent> <Leader>gm :Gdiffsplit!<CR>
nnoremap <silent> <Leader>gs :vertical Gstatus<CR>
nnoremap <Leader>gp :copen <Bar> :G poosh<CR>
nnoremap <silent> <Leader>m[ :diffget //2<CR>
nnoremap <silent> <Leader>m] :diffget //3<CR>
