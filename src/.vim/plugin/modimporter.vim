vim9script

command! -nargs=+ AddImport :call <SID>MI_add_import(<f-args>)
nmap ;i :AddImport<SPACE>
def MI_add_import(module: string, thingy: string='')
  var verb = 'import'
  var terminate = ';'
  var alternate = ''
  var import_pre = ''
  var import_post = ''
  if &filetype == 'perl' || expand('%:e') =~ '^\%(\.p[lm]\|\.t\)$'
     verb = 'use'
     terminate = ';'
     import_pre = ' qw( '
     import_post = ' ) '
  endif
  if &filetype == 'python' || expand('%:e') =~ '^\%(\.py\)$'
     verb = 'import'
     terminate = ''
     alternate = '\(from\s\+\(.\+\)\s\+\)\='
     if thingy != ''
       verb = 'from'
       import_pre = ' import '
     endif
  endif
  if &filetype == 'java' || expand('%:e') =~ '^\%(\.java\)$'
     verb = 'import'
     terminate = ';'
  endif

  var line_start = 1
  var line_end = line('$')

  var idx = 0
  var last = idx
  while idx < line_end 
    idx = idx + 1
    var line = getline(idx)
    if last == 0 && match(line, '^\s*$') == 0
      last = idx
    endif
    
    var found = match(line, '^\s*' .. verb)
    if found != -1 
      var parts = matchlist(line, '^\s*' .. alternate .. verb .. '\s\+\(.\+\)'  .. terminate .. '$')
      
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

      if current >=? module
        last = idx - 1
        break
      else
        last = idx
      endif
    endif 
    
  endwhile
  
  var import_line = verb .. ' ' .. module
  if thingy != ''
    import_line = import_line .. import_pre .. thingy .. import_post
  endif
  import_line = import_line .. terminate

  append( last,  import_line)
enddef
