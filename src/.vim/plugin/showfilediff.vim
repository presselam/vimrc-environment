vim9script

if exists("g:loaded_showfilediff")
  finish
endif

g:loaded_showfilediff = 1

g:sfd_mode = 'file'
g:sfd_priority = 10
g:sfd_debug_log = '/tmp/showdfilediff.log'

augroup ShowFileDiffGlobal
  autocmd!
  autocmd BufEnter * call SFD_setup()
  autocmd WinEnter * call SFD_setup()
  autocmd BufLeave * call SFD_teardown()
augroup END
 
# Set up initial highlight groups (unless already set)...
highlight default SHOW_DIFF_NEW ctermfg=black ctermbg=green cterm=bold gui=NONE guifg=#000000 guibg=#ffffff
highlight default SHOW_DIFF_OLD ctermfg=black ctermbg=red   cterm=bold gui=NONE guifg=#000000 guibg=#ffffff
highlight default SHOW_DIFF_CHG ctermfg=cyan  ctermbg=blue  cterm=bold gui=NONE guifg=#000000 guibg=#ffffff

def SFD_setup()

   # Set up autocommands ...
   augroup ShowFileDiffBuffer
      autocmd!
      autocmd TextChanged,BufWritePost  <buffer> call SFD_TextChanged()
   augroup END

   nmap <silent> ;c  :call <SID>BufferDiff('local')<CR>
   nmap <silent> ;cc :call <SID>BufferDiff('git')<CR>

   sign_define('ShowDiffAdd', {"text": '++', "texthl": "SHOW_DIFF_NEW"})
   sign_define('ShowDiffDel', {"text": '--', "texthl": "SHOW_DIFF_OLD"})
   sign_define('ShowDiffChg', {"text": '~~', "texthl": "SHOW_DIFF_CHG"})

   sign_unplace('mygroup', {"buffer": bufnr('')})

enddef

def SFD_teardown()
enddef

def SFD_TextChanged()
 sign_unplace('mygroup', {"buffer": bufnr('')})

  var text = join(getline(1, '$'), "\n")
  text = shellescape(text)

  var cmd = "echo " .. text .. " | diff -a -U0 -N " .. expand('%') .. " -"
  if g:sfd_mode == 'git'
    cmd = "echo " .. text .. " | diff -a -U0 -N -u <(git show :" .. expand('%') .. ") -"
  endif
  final output = system(cmd .. " |  grep -F '@@'")

  var id = 0
  for str in split(output, "\n")
    id += 1
    var parts = matchlist(str, '@@\s\+-\(\d\+\),\?\(\d*\)\s\++\(\d\+\),\?\(\d*\)\s\+@@')
    if empty(parts)
      echom "empty"
      continue
    endif

    final oldLine = str2nr(parts[1])
    final oldCount = (empty(parts[2]) ? 1 : str2nr(parts[2]))
    final newLine = str2nr(parts[3])
    final newCount = (empty(parts[4]) ? 1 : str2nr(parts[4]))

   # Handle Adds
   if oldCount == 0 && newCount > 0
      for i in range(newCount)
        sign_place(id, 'mygroup', 'ShowDiffAdd', bufnr(''), {"lnum": newLine + i, "priority": g:sfd_priority})
      endfor
      continue
   endif

   # Handle Deletes
   if oldCount > 0 && newCount == 0
      sign_place(id, 'mygroup', 'ShowDiffDel', bufnr(''), {"lnum": str2nr(parts[1]), "priority": g:sfd_priority})
      continue
   endif

    # Handle changed lines
    if oldCount == newCount
      for i in range(newCount)
        sign_place(id, 'mygroup', 'ShowDiffChg', bufnr(''), {"lnum": newLine + i, "priority": g:sfd_priority})
      endfor
      continue
    endif

    if oldCount < newCount 
      for i in range(newCount)
        if i < oldCount
          sign_place(id, 'mygroup', 'ShowDiffChg', bufnr(''), {"lnum": newLine + i, "priority": g:sfd_priority})
        else
          sign_place(id, 'mygroup', 'ShowDiffAdd', bufnr(''), {"lnum": newLine + i, "priority": g:sfd_priority})
        endif
      endfor
      continue
    endif

    system(cmd .. " > " .. g:sfd_debug_log)
    # echom "[" .. id .. "][" .. str .. "]"
    #   .. "[" .. oldLine .. "]"
    #   .. "[" .. oldCount .. "]"
    #   .. "[" .. newLine .. "]"
    #   .. "[" .. newCount .. "]"
    
  endfor
enddef

def BufferDiff(mode: string): void
  diffthis

  if mode == 'git'
    var cmd = ':%!git show :0:./' .. expand('%')
    vnew | exe cmd
  else
    vnew | read %% | normal! 1Gdd
  endif

  diffthis

  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" .. &ft
enddef
