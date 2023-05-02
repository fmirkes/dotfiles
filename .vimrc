:syntax on

:set number

:set tabstop=2
:set shiftwidth=2
:set expandtab

:set autoindent
:set smartindent

:set mouse-=a

:set ttimeoutlen=50

cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

