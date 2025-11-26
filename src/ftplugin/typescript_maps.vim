if exists("b:did_typescript_maps")
	finish
endif
let b:did_typescript_maps = 1

"=====[ Perltidy ]===========================================================
Nmap ;p   [tidy the current buffer]   :%!clang-format -style=file %<CR>
