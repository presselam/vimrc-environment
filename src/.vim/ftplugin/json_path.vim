vim9script

const hlGroup = 'JsonPathVirtualText'
#if !hlexists(hlGroup)
#    highlight link JsonPathVirtualText Special
#    highlight JsonPathVirtualText ctermbg=blue ctermfg=blue
#endif

b:JsonPathDelimiter = '.'
var marker = 0

if has('textprop')
  augroup TrackJsonPath
    autocmd!
    autocmd CursorMoved  <buffer> call JSONPath()
    autocmd CursorMovedI <buffer> call JSONPath()
  augroup END

  var propType = prop_type_get(hlGroup)
  if propType == {}
    prop_type_add(hlGroup, {highlight: 'Special'})
  endif
endif

def JSONPath()

  var linenum = getpos('.')[1]
  if marker == linenum
    return
  endif
  marker = linenum

  var name = ''
  var token = ''
  var nodes = []
  var i = 1
  while i <= linenum
    var ln = getline(i)
    var parts = matchlist(ln, '^\s*\("\(.\{-}\)"\s*:\s*\|\s*\)\(["{\[\d\]}]\)')
    if len(parts) != 0
      name = parts[2]
      token = parts[3]
      if (token ==# '{' || token == '[')
        add(nodes, name)
      endif
      if token == '}' || token == ']'
        if len(nodes) > 0 
          remove(nodes, -1)
        endif
      endif
    endif

    i = i + 1
  endwhile

  var pad = (winwidth(0) / 2) - len(getline('.'))
  if pad < 1
    pad = 1
  endif

  # echom '[' .. len(nodes) .. "][" .. name .. "][" .. token .. "][" .. &signcolumn .. "]"
  
  var path = b:JsonPathDelimiter .. join(filter(copy(nodes), 'v:val != ""'), b:JsonPathDelimiter)
  if name != '' 
    if token == '"'
    path = path .. b:JsonPathDelimiter .. name
    endif
  endif



  prop_remove({type: hlGroup})
   prop_add(linenum, 0, {
     type: hlGroup,
     text: ' ' .. path,
     text_padding_left: pad,
     text_wrap: 'wrap'
   })

enddef

