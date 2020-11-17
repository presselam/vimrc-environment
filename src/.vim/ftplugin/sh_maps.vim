if exists("b:did_sh_maps")
	finish
endif
let b:did_sh_maps = 1

nmap <F2>   :! bash %<CR>

"====[ ALE Options ]========================================
let g:ale_sh_shellcheck_exclusions='SC1091,SC1090'
let g:ale_sh_shellcheck_dialect = 'bash'
