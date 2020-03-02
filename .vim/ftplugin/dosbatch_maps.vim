if exists("b:did_dosbatch_maps")
  finish
endif
let b:did_dosbatch_maps = 1

nmap <F2> :!cmd.exe /c %<CR>


