if exists("b:did_perl_maps")
	finish
endif
let b:did_perl_maps = 1

set iskeyword+=:

set complete+=k~/.vim/extras/autocomplete.perl

nmap gx yiw/^sub\s\+<C-R>"<CR>
nmap <F2>   :! %<CR>
nmap <F3>   :! perldoc %<CR>
nmap <F4>   :w<CR>:! perltidy -pbp -b -nst %<CR>:e!<CR>
nmap <F9>   :! dprofpp -u -p %<CR>


"=====[ Shortcuts ]=========================================================
iab utq quick(); use Toolkit;<ESC>3ba
iab upo printObject(); use Toolkit;<ESC>3ba

"=====[ Perltidy ]===========================================================
Nmap ;p   [Perltidy the current buffer]   :w<CR>:! perltidy -b -nst %<CR>:e!<CR>
Nmap ;pp  [Perltidy diff the current buffer] :call Perltidy_diff()<CR>

"====[ Perldoc  ]===========================================
" put the cursor over a perl function and try backslash-pf to see perldoc
nmap <Leader>pf :!perldoc -f <cword><CR>

" put the cursor over a perl module name and try backslash-pd to see perldoc
nmap <Leader>pd :!perldoc <cword><CR>

" put the cursor over a perl module name and try backslash-pd to see perldoc
nmap <Leader>pm :!perldoc -m <cword><CR>

Nmap <expr> ?? [Go to documentation] CallPerldoc()
set keywordprg=pd

function! CallPerldoc ()
    " When editing Vim files, revert to :help...
    if &filetype == 'vim' || &buftype == 'help'
        return ":help "

    " Otherwise use Perldoc...
    else
        let target = matchstr(expand('<cfile>'), '\w\+\(::\w\+\)*')
        set wildmode=list:full
        return ":Perldoc "
    endif
endfunction

"=====[ Emphasize typical mistakes in Vim and Perl files ]=========
" Add a new high-visibility highlight combination...
highlight WHITE_ON_RED    ctermfg=white  ctermbg=red
" Emphasize undereferenced references...
call matchadd('WHITE_ON_RED', '_ref[ ]*[[{(]\|_ref[ ]*-[^>]')

" =====[ Smart completion via <TAB> and <S-TAB> ]=============

runtime plugin/smartcom.vim

" Add extra completions (mainly for Perl programming)...

let ANYTHING = ""
let NOTHING  = ""
let EOL      = '\s*$'

                " Left     Right      Insert                             Reset cursor
                " =====    =====      ===============================    ============
call SmartcomAdd( '<<',    ANYTHING,  '>>',                              {'restore':1} )
call SmartcomAdd( '<<',    '>>',      "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '«',     ANYTHING,  '»',                               {'restore':1} )
call SmartcomAdd( '«',     '»',       "\<CR>\<ESC>O\<TAB>"                             )
call SmartcomAdd( '{{',    ANYTHING,  '}}',                              {'restore':1} )
call SmartcomAdd( '{{',    '}}',      NOTHING,                                         )
call SmartcomAdd( 'qr{',   ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'qr{',   '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>"                 )
call SmartcomAdd( 'm{',    ANYTHING,  '}xms',                            {'restore':1} )
call SmartcomAdd( 'm{',    '}xms',    "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( 's{',    ANYTHING,  '}{}xms',                          {'restore':1} )
call SmartcomAdd( 's{',    '}{}xms',  "\<CR>\<C-D>\<ESC>O\<C-D>\<TAB>",                )
call SmartcomAdd( '\*\*',  ANYTHING,  '**',                              {'restore':1} )
call SmartcomAdd( '\*\*',  '\*\*',    NOTHING,                                         )

" Handle single : correctly...
call SmartcomAdd( '^:\|[^:]:',  EOL,  "\<TAB>" )

" Perl keywords...
call SmartcomAdd( '^\s*for',   EOL,    " my $___ (___) {\n___\n}\n___",        {'filetype':'perl'} )
call SmartcomAdd( '^\s*if',    EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*while', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*given', EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )
call SmartcomAdd( '^\s*when',  EOL,    " (___) {\n___\n}\n___",                {'filetype':'perl'} )

" Complete Perl module loads with the names of Perl modules...
call SmartcomAddAction( '^\s*use\s\+\k\+', "",
\                       'set complete=k~/.vim/perlmodules|set iskeyword+=:'
\)

" In the middle of a keyword: delete the rest of the keyword before completing...
                " Left     Right                    Insert
                " =====    =====                    =======================
"call SmartcomAdd( '\k',    '\k\+\%(\k\|\n\)\@!',    "\<C-O>cw\<C-X>\<C-N>",           )
"call SmartcomAdd( '\k',    '\k\+\_$',               "\<C-O>cw\<C-X>\<C-N>",           )

"=====[ Search folding ]=====================

" Don't start new buffers folded
set foldlevelstart=99

" Highlight folds
highlight Folded  ctermfg=cyan ctermbg=black

" Toggle on and off...
nmap <silent> <expr>  zz  FS_ToggleFoldAroundSearch({'context':1})

" Show only sub defns (and maybe comments)...
let perl_sub_pat = '^\s*\%(sub\|func\|method\|package\)\s\+\k\+'
let vim_sub_pat  = '^\s*fu\%[nction!]\s\+\k\+'
augroup FoldSub
    autocmd!
    autocmd BufEnter * nmap <silent> <expr>  zp  FS_FoldAroundTarget(perl_sub_pat,{'context':1})
    autocmd BufEnter * nmap <silent> <expr>  za  FS_FoldAroundTarget(perl_sub_pat.'\\|^\s*#.*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  zp  FS_FoldAroundTarget(vim_sub_pat,{'context':1})
    autocmd BufEnter *.vim,.vimrc nmap <silent> <expr>  za  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
    autocmd BufEnter * nmap <silent> <expr>             zv  FS_FoldAroundTarget(vim_sub_pat.'\\|^\s*".*',{'context':0, 'folds':'invisible'})
augroup END

" Show only C #includes...
nmap <silent> <expr>  zu  FS_FoldAroundTarget('^\s*use\s\+\S.*;',{'context':1})


"let perl_fold = 1
"let perl_nofold_packages = 1
