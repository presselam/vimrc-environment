if exists("b:did_sh_maps")
	finish
endif
let b:did_sh_maps = 1

nmap <F2>   :! bash %<CR>
