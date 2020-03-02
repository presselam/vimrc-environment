if exists("b:did_perl_test")
	finish
endif
let b:did_perl_test = 1

noremap <Leader>t :call RunTest()<CR>
noremap <Leader>o :call OpenTestFile()<CR>

function! RunTest()
  let testcase = expand("%:t:r")
  let cmd = ":! prove -v -It/lib t/" . testcase . "*.t"
  
  execute cmd
endfunction

if !exists("*OpenTestFile")
  function! OpenTestFile()
    find t/%:t:r*.t 
  endfunction
endif

