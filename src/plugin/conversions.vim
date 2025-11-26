vim9script

const hlGroup = 'ConversionText'
if !hlexists(hlGroup)
#    highlight link JsonPathVirtualText Special
    highlight ConversionText ctermbg=Brown ctermfg=Yellow guibg=Brown guifg=Yellow
endif

var popUpId = 0

if has('textprop')
  augroup ConversionTracking
    autocmd!
    autocmd CursorMoved,CursorMovedI  <buffer> call ConvertClear()
  augroup END

  var propType = prop_type_get(hlGroup)
  if propType == {}
    prop_type_add(hlGroup, {highlight: 'Special'})
  endif

  noremap <silent> ;cb :call ConvertBytes()<CR>
  noremap <silent> ;ce :call ConvertEpoch()<CR>
  noremap <silent> ;cd :call ConvertDuration()<CR>
endif

def g:ConvertDuration()

  final word = expand('<cword>')
  var seconds = str2nr( word )
  if seconds == 0
    return
  endif

  final tmparts = []
  var part = seconds / 86400
  if len(tmparts) > 0 || part > 0
    add(tmparts, repeat('0', 2 - len(part)) .. part)
  endif
  seconds = seconds % 86400

  part = seconds / 3600
  if len(tmparts) > 0 || part > 0
  add(tmparts, repeat('0', 2 - len(part)) .. part)
  endif
  seconds = seconds % 3600

  part = seconds / 60
  if len(tmparts) > 0 || part > 0
    add(tmparts, repeat('0', 2 - len(part)) .. part)
  endif
  seconds = seconds % 60
  if len(tmparts) > 0 || part > 0
    add(tmparts, repeat('0', 2 - len(seconds)) .. seconds)
  endif

  final tmstamp = join(tmparts, ':')

  final linenum = getpos('.')[1]
  final linecol = getpos('.')[2]
  final startPos = matchstrpos(getline('.'), word, linecol - len(word))[1]
  popUpId = popup_create(tmstamp, {
    line: linenum + 1,
    col: startPos,
    pos: 'topleft',
    padding: [0, 1, 0, 1],
   })
enddef

def g:ConvertEpoch()

  final linenum = getpos('.')[1]
  final linecol = getpos('.')[2]
  final word = expand('<cword>')
  var epoch = str2nr( word )
  if epoch == 0
    return
  endif

  var ms = '000'
  if len(epoch) > 10
    ms = string(epoch % 1000)
    ms = repeat('0', 3 - len(ms)) .. ms

    epoch = epoch / 1000
  endif

  final timestamp = strftime('%Y-%m-%d %H:%M:%S', epoch)

  final startPos = matchstrpos(getline('.'), word, linecol - len(word))[1]
  popUpId = popup_create(timestamp .. '.' .. ms, {
    line: linenum + 1,
    col: startPos,
    pos: 'topleft',
    padding: [0, 1, 0, 1],
   })
enddef

def g:ConvertBytes()

  final linenum = getpos('.')[1]
  final linecol = getpos('.')[2]
  final word = expand('<cword>')
  final bytes = str2nr( word )
  if bytes == 0
    return
  endif

  var startPos = matchstrpos(getline('.'), word, linecol - len(bytes))[1]
  var units = ['kb', 'mb', 'gb', 'tb', 'pb', 'eb']

  final result = []
  var ordinal = bytes / 1000
  while ordinal > 0
    var unit = units[0]
    units = units[1 : ]

    add(result, ordinal .. ' ' .. unit)
    ordinal = ordinal / 1000
  endwhile

  reverse(result)

  popUpId = popup_create(result, {
    line: linenum + 1,
    col: startPos,
    pos: 'topleft',
    padding: [0, 1, 0, 1],
    border: [1, 1, 1, 1],
    highlight: hlGroup,
   })
enddef

def g:ConvertClear()
  if popUpId != 0
    popup_close(popUpId)
    popUpId = 0
  endif
enddef
