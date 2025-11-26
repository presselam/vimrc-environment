if exists("b:did_javascript_maps")
	finish
endif
let b:did_javascript_maps = 1

set iskeyword+=:

"=====[ Shortcuts ]=========================================================
iab utq quick(); use Toolkit;<ESC>3ba
iab upo printObject(); use Toolkit;<ESC>3ba

"=====[ Perltidy ]===========================================================
Nmap ;p   [tidy the current buffer]   :%!clang-format -style=file %<CR>
