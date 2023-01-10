
vim9script

if exists("g:ale_customized")
  finish
endif
g:ale_customized = 1


&t_Cs = "\e[4:3m"
&t_Ce = "\e[4:0m"

hi ALEVirtualTextWarning  term=italic    ctermfg=DarkMagenta        guifg=#00aaaa    cterm=italic,undercurl

