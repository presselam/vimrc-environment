" sh_synwrite.vim : check syntax of BASH before writing
" author : Ricardo Signes <rjbs-vim@public.manxome.org>


"" abort if b:did_perl_synwrite is true: already loaded or user pref
if exists("b:did_sh_synwrite")
	finish
endif
let b:did_sh_synwrite = 1

" set defaults, to which s:MostLocal() will fall back
let s:default_perl_synwrite_qf = 0
let s:default_perl_synwrite_au = 0
let s:default_perl_synwrite_perlopts = ""

" get the named var from the first available of: buffer-local, global, default
function! s:MostLocal(varname)
  if exists("b:" . a:varname)
    return b:{a:varname}
  elseif exists(a:varname)
    return {a:varname}
  else
    return s:default_{a:varname}
  endif
endfun

"" execute the given do_command if the buffer is syntactically correct perl
"" -- or if do_anyway is true
function! s:ShellSynCheck(do_anyway,do_command)
  let command = "!shellcheck -s bash -f gcc " . expand("%")

  " we need to cat here because :exec would add a space between ! and command
  " let to_exec = "write !" . command
  exec "write" command

	silent! cgetfile " try to read the error file
	if !v:shell_error || a:do_anyway
		exec a:do_command
		set nomod
	endif
endfunction

"" the :Write command
command -buffer -nargs=* -complete=file -range=% -bang Write call s:ShellSynCheck("<bang>"=="!","<line1>,<line2>write<bang> <args>")
