vim9script

if exists("g:gitlab_maps")
  finish
endif
g:gitlab_maps = 1

autocmd BufRead,BufNewFile */.gitlab-ci.yml map <buffer> <F6> :!git add %; git commit -m 'debug .gitlab-ci.yml certs'; git push<CR>

