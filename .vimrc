:syntax on

:set number

:set tabstop=2
:set shiftwidth=2
:set expandtab

:set autoindent
:set smartindent

:set ignorecase
:set smartcase

:set mouse=

:set ttimeoutlen=50

augroup RestoreCursor
  autocmd!
  autocmd BufReadPost *
    \ let line = line("'\"")
    \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
    \      && index(['xxd', 'gitrebase'], &filetype) == -1
    \      && !&diff
    \ |   execute "normal! g`\""
    \ | endif
augroup END

