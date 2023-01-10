vim9script

if exists("g:loaded_styles")
  finish
endif
g:loaded_styles = 1

noremap <silent> <F5> :call KebabCase()<CR>
noremap <silent> <F6> :call CamelCase()<CR>
noremap <silent> <F7> :call SnakeCase()<CR>
noremap <silent> <F8> :call PascalCase()<CR>

def g:PascalCase(): void

  setlocal nosmartcase
  setlocal iskeyword+=-
  var varname: string
  varname = expand('<cword>')

  var word: string
  word = substitute(varname, '[-_]\(\l\)', '\u\1', 'g')
  word = substitute(word, '^.', '\u&', '')

  var currline: string
  currline = getline('.')
  currline = substitute(currline, varname, word, '')
  call setline('.', currline)

enddef

def g:KebabCase(): void

  setlocal nosmartcase
  setlocal iskeyword+=-
  var varname: string
  varname = expand('<cword>')

  var word: string
  word = substitute(varname, '^.', '\l&', '')
  word = substitute(word, '\(\u\)', '-\1', 'g')
  word = substitute(word, '_', '-', 'g')
  word = tolower(word)

  var currline: string
  currline = getline('.')
  currline = substitute(currline, varname, word, '')
  call setline('.', currline)

enddef

def g:CamelCase(): void

  setlocal nosmartcase
  setlocal iskeyword+=-
  var varname: string
  varname = expand('<cword>')

  var word: string
  word = substitute(varname, '[-_]\(\l\)', '\u\1', 'g')

  var currline: string
  currline = getline('.')
  currline = substitute(currline, varname, word, '')
  call setline('.', currline)

enddef

def g:SnakeCase(): void

  setlocal nosmartcase
  setlocal iskeyword+=-
  var varname: string
  varname = expand('<cword>')
  setlocal iskeyword-=-

  var word: string
  word = substitute(varname, '^.', '\l&', '')
  word = substitute(word, '\(\u\)', '_\1', 'g')
  word = tolower(word)

  var currline: string
  currline = getline('.')
  currline = substitute(currline, varname, word, '')
  call setline('.', currline)

enddef

defcompile
