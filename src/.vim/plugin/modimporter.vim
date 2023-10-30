vim9script

if exists("g:loaded_modimporter")
  finish
endif

g:loaded_modimporter = 1

command! -nargs=1 AddImport :call <SID>MI_add_import(<q-args>)
nmap ;i :AddImport<SPACE>
def MI_add_import(module: string)
  var verb = 'import'
  var terminate = ';'
  if &filetype == 'perl' || expand('%:e') =~ '^\%(\.p[lm]\|\.t\)$'
     verb = 'use'
     terminate = ';'
  endif
  if &filetype == 'python' || expand('%:e') =~ '^\%(\.py\)$'
     verb = 'import'
     terminate = ''
  endif
  if &filetype == 'java' || expand('%:e') =~ '^\%(\.java\)$'
     verb = 'import'
     terminate = ';'
  endif

  # echom "[" .. verb .. "][" .. terminate .. "]"

  var line_start = 1
  var line_end = line('$')

  var idx = 0
  while idx < line_end 
    idx = idx + 1
    var line = getline(idx)
    var pos = stridx(line, verb)
    if pos != -1
      var parts = matchlist(line, '^\s*' .. verb .. '\s\+\(.\+\)'  .. terminate .. '$')
      var current = parts[1]
      
      if module[0] =~ '[a-z0-9]'
        if current[0] =~ '[A-Z]'
          continue
        endif
      else
        if current[0] =~ '[a-z0-9]'
          continue
        endif
      endif

      # echom "[" .. idx .. "][" .. current .. "][" .. module .. "]"
      if current >=? module
        append( idx - 1, verb .. ' ' .. module .. ';')
        break
      endif
    endif 
    
  endwhile
enddef


