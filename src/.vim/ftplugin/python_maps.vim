if exists("b:did_python_maps")
	finish
endif
let b:did_python_maps = 1

set iskeyword-=:

let b:cmt = '# '

nmap <F2>   :!python %<CR>


"====[ tweak ale for python ]===============================
Nmap ;p   [autoformat the current buffer]   :ALEFix<CR>
let b:ale_fixers=['black']
let g:ale_linters = { 'python': ['pylint'] }

let current_dir = expand('%:p:h')
while current_dir !=# '/'  " Loop until root directory is reached
  let venv = glob(current_dir . '/.*-venv/', 1)
  if venv != ''
    let g:ale_python_pylint_options = '--init-hook ''import sys; sys.path.append("' . venv . '/lib/python3.11/site-packages")'''
  endif

  let current_dir = fnamemodify(current_dir, ':h')  " Move up one directory
endwhile


"====[ Indent Guides ]======================================
set ts=4
set sw=0
set et
"let g:indentLine_color_term = 239
"let g:indentLine_char = '|'
"let g:indentLine_concealcursor = 'inc'
"let g:indentLine_conceallevel = 1
"let g:indent_guides_start_level = 1
"let g:indent_guides_guide_size = 1
"IndentGuidesEnable
"hi IndentGuidesOdd  ctermbg=lightgrey
"hi IndentGuidesEven ctermbg=darkgrey
