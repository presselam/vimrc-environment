if exists("b:did_perl_newsub")
	finish
endif
let b:did_perl_newsub = 1

noremap <Leader>ns :call Newsub()<CR>

function! Newsub()
  let pod  = "=item * " . expand("<cword>")
  let word = "sub " . expand("<cword>") . "{}"
  let ln = search("__.*__", 'nW')
  if ln == 0
    call append('$', pod)
    call append('$', "=cut")
    call append('$', word)
  else
    call append('$', pod)
    call append('$', "=cut")
    call append(ln-1, word)
  endif
endfunction

function! ShowFuncName()
  let lnum = line(".")
  let col = col(".")
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
  echohl None
  call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfunction

map <Leader>f :call ShowFuncName() <CR>

