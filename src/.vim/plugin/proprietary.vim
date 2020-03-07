" Vim global plugin NextGen specific stuffs
"
" Last change:  Mon Sept 18 EST 2017
" Maintainer:   Andrew Pressel

" If already loaded, we're done...
if exists("loaded_proprietary")
    finish
endif
let loaded_proprietary = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

augroup RAF
  autocmd!
  autocmd BufNewFile *.raf 0r !file_template <afile>
  autocmd BufNewFile *.raf /Filename[ \t]Here/
augroup END  


" Restore previous external compatibility options
let &cpo = s:save_cpo
