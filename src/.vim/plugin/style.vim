if exists("loaded_styles")
  finish
endif
let loaded_styles = 1
"
"echo 'loaded'

map <F6> :call <SID>SnakeCase()<CR>


function! s:SnakeCase ()

  setlocal iskeyword+=-
  let varname = expand('<cword>')
  setlocal iskeyword-=-
  let word = substitute(varname,'[a-z]','/','ig')
"  echo word
"  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
"  echo word
"  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
"  echo word
"  let word = substitute(word,'[.-]','_','g')
"  echo word
  let retname = tolower(word)
  echo '[' . retname . ']'
"  for s:item in split(varname, '\zs')
"    echoerr s:item
"  endfor

endfunction
