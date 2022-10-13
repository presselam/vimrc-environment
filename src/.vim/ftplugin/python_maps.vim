if exists("b:did_python_maps")
	finish
endif
let b:did_python_maps = 1

set iskeyword+=:

let b:cmt = '# '

nmap <F2>   :!python %<CR>

"=====[ Perltidy ]===========================================================
let b:ale_fixers=['black']
Nmap ;p   [autoformat the current buffer]   :ALEFix<CR>

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
