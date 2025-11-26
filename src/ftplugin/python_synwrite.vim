" python_synwrite.vim : check syntax of python before writing
" author : Ricardo Signes <rjbs-vim@public.manxome.org>
" $Id: /my/rjbs/conf/vim/python_synwrite.vim 17554 2006-01-11T19:22:06.444484Z rjbs  $

""" to make syntax checking happen automatically on write, set
""" python_synwrite_au; this is quirky, though, and isn't really advised
""" failing that, this script will map :Write to act like :write, but 
""" check syntax before writing;  :W[rite]! will write even if the syntax
""" check fails

""" if you have installed Vi::QuickFix (1.124 or later) you can assign
""" a true value to python_synwrite_qf to use it to provide quickfix data
""" for the buffer

""" You can use the following lines to set python_synwrite_qf automatically based
""" on whether it is likely to work:
"""   silent call system("python -e0 -MVi::QuickFix")
"""   let python_synwrite_qf = ! v:shell_error

"" abort if b:did_python_synwrite is true: already loaded or user pref
if exists("b:did_python_synwrite")
	finish
endif
let b:did_python_synwrite = 1

" set defaults, to which s:MostLocal() will fall back
let s:default_python_synwrite_qf = 0
let s:default_python_synwrite_au = 0
let s:default_python_synwrite_pythonopts = ""

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

"" execute the given do_command if the buffer is syntactically correctpython 
"" -- or if do_anyway is true
function! s:PythonSynDo(do_anyway,do_command)
  let command = "!python -m py_compile"

"	if (s:MostLocal("python_synwrite_au"))
" this env var tells Vi::QuickFix to replace "-" with actual filename
"		let $VI_QUICKFIX_SOURCEFILE=expand("%")
"    let command = command . " -MVi::QuickFix"
"	endif

" respect taint checking
"  if (match(getline(1), "^#!.*perl.\\+-T") == 0)
"    let command = command . " -T"
"  endif

  let command = command . " " . s:MostLocal("python_synwrite_pythonopts")

  " we need to cat here because :exec would add a space between ! and command
  " let to_exec = "write !" . command
  exec "write" command

	silent! cgetfile " try to read the error file
	if !v:shell_error || a:do_anyway
		exec a:do_command
		set nomod
	endif
endfunction

"" set up the autocommand, if b:python_synwrite_au is true
if (s:MostLocal("python_synwrite_au") > 0)
	let b:undo_ftplugin = "au! python_synwrite * " . expand("%")

	augroup python_synwrite
		exec "au BufWriteCmd,FileWriteCmd " . expand("%") . " call s:PythonSynDo(0,\"write <afile>\")"
	augroup END
endif

"" the :Write command
command -buffer -nargs=* -complete=file -range=% -bang Write call s:PythonSynDo("<bang>"=="!","<line1>,<line2>write<bang> <args>")
