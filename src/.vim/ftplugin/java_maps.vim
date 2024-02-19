if exists("b:did_java_maps")
	finish
endif
let b:did_java_maps = 1

"autocmd FileType java setlocal omnifunc=javacomplete#Complete

set iskeyword+=:

"=====[ Shortcuts ]=========================================================
"iab utq quick(); use Toolkit;<ESC>3ba
"iab upo printObject(); use Toolkit;<ESC>3ba

"====[ clang-tidy ]=========================================
let g:ale_java_checkstyle_config = '/usr/share/checkstyle/google_checks.xml'
Nmap ;p   [tidy the current buffer]   :%!clang-format -style=file:$HOME/.clang-format %<CR>
