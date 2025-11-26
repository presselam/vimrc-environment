vim9script

command! -nargs=+ AddImport :call <SID>MI_add_import(<f-args>)
nmap ;i :AddImport<SPACE>

def MI_add_import(module: string, thingy: string='')
  var verb = 'import'
  var anchor = verb
  var terminate = ';'
  var alternate = ''
  var import_pre = ''
  var import_post = ''
  var quote = ''
  var regex = '^\s*' .. alternate .. verb .. '\s\+\(.\+\)'  .. terminate .. '$'
  if &filetype == 'perl' || expand('%:e') =~ '^\%(\.p[lm]\|\.t\)$'
     verb = 'use'
     terminate = ';'
     import_pre = ' qw( '
     import_post = ' ) '
  endif
  if &filetype == 'python' || expand('%:e') =~ '^\%(\.py\)$'
     terminate = ''
     alternate = '\(from\s\+\(.\+\)\s\+\)\='
     if thingy != ''
       verb = 'from'
       anchor = verb
       import_pre = ' import '
     endif
     regex = '^\s*' .. alternate .. verb .. '\s\+\(.\+\)'  .. terminate .. '$'
  endif
  if &filetype == 'java' || expand('%:e') =~ '^\%(\.java\)$'
     terminate = ';'
  endif
  if &filetype == 'go' || expand('%:e') =~ '^\%(\.go\)$'
     anchor = 'import\s\+('
     verb = ''
     terminate = ''
     quote = '"'
     regex = '^\s*\(\w\+\)\{0,1}\s*"\(.\+\)\s*$'
  endif

  var line_start = 1
  var line_end = line('$')

  var idx = 0
  var last = idx
  var wanted = false
  while idx < line_end 
    idx = idx + 1
    var line = getline(idx)
    if last == 0 && match(line, '^\s*$') == 0
      last = idx
    endif
    
    var found = match(line, '^\s*' .. anchor)
    if found != -1 
      wanted = true
    endif  

    if wanted
      var parts = matchlist(line, regex)
      
      if len(parts) > 0 
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
    endif 
    
  endwhile
  
  var import_line = verb .. ' ' .. quote .. module .. quote
  if thingy != ''
    import_line = import_line .. import_pre .. thingy .. import_post
  endif
  import_line = import_line .. terminate

  append( last,  import_line)
enddef
