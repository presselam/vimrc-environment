vim9script

if exists("g:loaded_formatting")
  finish
endif
g:loaded_formatting = 1

command! -nargs=1 PadTo :call PadLine(<q-args>)
def g:PadLine(column: string)
  # find the first column position with a whitespace
  # pad out from there
  var pos = virtcol('.')
  var currline = getline('.')
  while strcharpart(strpart(currline, pos - 1), 0, 1) != ' '
    if pos == len(currline)
      break
    endif
    pos += 1
  endwhile

  var strEnd = strpart(currline, pos - 1)
  var strClean = substitute(strEnd, '^\s*\(.\{-}\)\s*$', '\1', '')

  setline('.', strpart(currline, 0, pos - 1) .. repeat(' ', str2nr(column) - pos) .. strClean)
enddef

noremap \\ :call PadBlock()<CR>
def g:PadBlock()

  var lnum = getpos('.')[1]

  var buffer = []
  var width = 0

  var start = lnum
  var currline = getline(start)
  while currline[-1] == '\'
    currline = strpart(currline, 0, len(currline) - 1)
    currline = trim(currline, " \n\r\t", 2)
    insert(buffer, currline)

    var wide = len(currline)
    if width < wide
      width = wide
    endif

    start -= 1
    currline = getline(start)
  endwhile

  lnum += 1
  currline = getline(lnum)
  while currline[-1] == '\'
    currline = strpart(currline, 0, len(currline) - 1)
    currline = trim(currline, " \n\r\t", 2)
    add(buffer, currline)

    var wide = len(currline)
    if width < wide
      width = wide
    endif

    lnum += 1
    currline = getline(lnum)
  endwhile

  lnum = start + 1
  for line in buffer
    setline(lnum, line .. repeat(' ', width - len(line)) .. ' \')
    lnum += 1
  endfor
 

enddef

noremap == :call PadAssignments()<CR>
def g:PadAssignments()

  var pad = ' '
  var pivot = matchstr(getline('.'), '\%' .. col('.') .. 'c.')
  var nextchar = matchstr(getline('.'), '\%' .. (col('.') + 1) .. 'c.')
  if index(['=', '>'], nextchar) >= 0
    pad = ''
  endif 
  # echom "[" .. pivot .. "][" .. nextchar .. "]"

  var lnum = getpos('.')[1]

  var buffer = []
  var width = 0

  var start = lnum
  var currline = getline(start)
  var curridx = stridx(currline, pivot)
  while curridx != -1
    var lval = trim(strpart(currline, 0, curridx), " \n\r\t", 2)
    var rval = trim(strpart(currline, curridx + 1))
    insert(buffer, [lval, rval])

    var wide = len(lval)
    if width < wide
      width = wide
    endif
    #  echom "[" .. lval .. "][" .. rval .. "][" .. wide .. "][" .. width .. "]"

    start -= 1
    currline = getline(start)

    # stop at open braces { or comments
    if currline =~ '\({\|^\s*#\)'
      curridx = -1
      continue
    endif
    curridx = stridx(currline, pivot)
  endwhile

  lnum += 1
  currline = getline(lnum)
  curridx = stridx(currline, pivot)
  while curridx != -1 
    var lval = trim(strpart(currline, 0, curridx), " \n\r\t", 2)
    var rval = trim(strpart(currline, curridx + 1))
    add(buffer, [lval, rval])

    var wide = len(lval)
    if width < wide
      width = wide
    endif
#    echom "[" .. lval .. "][" .. rval .. "][" .. wide .. "][" .. width .. "]"

    lnum += 1
    currline = getline(lnum)

    # stop at closing braces } or comments
    if currline =~ '\(}\|^\s*#\)'
      curridx = -1
      continue
    endif
    curridx = stridx(currline, pivot)
  endwhile

  lnum = start + 1
  for line in buffer
    setline(lnum, line[0] .. repeat(' ', width - len(line[0])) .. ' ' .. pivot .. pad .. line[1])
    lnum += 1
  endfor
enddef

defcompile
