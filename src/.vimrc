set ruler
set expandtab
"=====[ Auto/Smart Indent ]======
set ai sm smd
"=====[ Smarter search ]=======
set incsearch
set ignorecase
set smartcase
set ts=2
set sw=2
set splitbelow
set splitright
set hlsearch
colorscheme elflord
set background=dark
syntax on
set title
"           +--Disable hlsearch while loading viminfo
"           | +--Remember marks for last 500 files
"           | |    +--Remember up to 10000 lines in each register
"           | |    |      +--Remember up to 1MB in each register
"           | |    |      |     +--Remember last 1000 search patterns
"           | |    |      |     |     +---Remember last 1000 commands
"           | |    |      |     |     |
"           v v    v      v     v     v
set viminfo=h,'500,<10000,s1000,/1000,:1000
set wildmode=list:longest,full
set printoptions=number:y

"====[ Pathogen Runtime ]===================================
execute pathogen#infect()

"====[ Color ANSI Codes ]===================================
autocmd BufNewFile,BufReadPost * ColorToggle

"====[ Goto last location in non-empty files ]=======
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

filetype plugin on

"=====[ Enable Nmap command for documented mappings ]================
runtime plugin/documap.vim

"====[ Work Specific Mappings ]=============================
if filereadable("plugin/proprietary.vim")
  runtime plugin/proprietary.vim
endif

"====[ Edit and auto-update this config file and plugins ]==========

augroup VimReload
autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

Nmap           ;r   [reload .vimrc]        :source $MYVIMRC<CR>
Nmap <silent>  ;v   [Edit .vimrc]          :next $MYVIMRC<CR>
Nmap           ;vv  [Edit .vim/plugin/...] :next ~/.vim/plugin/

Nmap <silent>  ;n   [toggle numbers]        :set number!<CR>

set t_Co=256
set t_Sf=[3%p1%dm

hi Search ctermfg=Grey ctermbg=BLUE
hi Comment ctermfg=white

"=====[ Make * respect smartcase and also set @/ (to enable 'n' and 'N') ]======
nmap *  :let @/ = '\<'.expand('<cword>').'\>' ==? @/ ? @/ : '\<'.expand('<cword>').'\>'<CR>:set hls<CR>

" use CTRL-K to determine the keystroke for the terminal
if has('unix')
  noremap <S-UP>    <C-W>k
  noremap <S-DOWN>  <C-W>j
  noremap <S-RIGHT> <C-W>l
  noremap <S-LEFT>  <C-W>h
else
  noremap <ESC>[A <C-W>k
  noremap <ESC>[B <C-W>j
  noremap <ESC>[C <C-W>l
  noremap <ESC>[D <C-W>h
endif

noremap <Leader>s :%s/<C-R><C-w>//<CR>
noremap <Leader>mt :!make test TEST_VERBOSE=1<CR>
noremap <Leader>mi :!make install<CR>

noremap  <F9>  :ga<CR>
"nnoremap * :set hls<CR>:exec "let @/='\\<".expand("<cword>")."\\>'"<CR>
noremap  <BS>  :set hls!<CR>
noremap  <F10> 0o######## DEV-ONLY ########<ESC>j0
noremap  <F12> :!cvs diff -w % <Bar> colorize<CR>
nnoremap <silent> <Leader>k mk:exe 'match Search /<Bslash>%'.line(".").'l/'<CR>
"=====[ Extend a previous match ]=====================================
nnoremap //   /<C-R>/
nnoremap ///  /<C-R>/\<BAR>
"=====[ remove trailing whitespace ]==================================
Nmap <silent> <BS><BS>  [Remove trailing whitespace] mz:call TrimTrailingWS()<CR>`z

function! TrimTrailingWS ()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction

"====[ Use persistent undo ]=================

if has('persistent_undo')
    " Save all undo files in a single location (less messy, more risky)...
    set undodir=$HOME/.VIM_UNDO_FILES

    " Save a lot of back-history...
    set undolevels=5000

    " Actually switch on persistent undo
    set undofile
endif

"=====[ Configure % key (via matchit plugin) ]==============================

" Match angle brackets...
if !has('win32')
  set matchpairs+=<:>,«:»
endif  

" Match double-angles, XML tags and Perl keywords...
let TO = ':'
let OR = ','
let b:match_words =
\
\                          '<<' .TO. '>>'
\
\.OR.     '<\@<=\(\w\+\)[^>]*>' .TO. '<\@<=/\1>'
\
\.OR. '\<if\>' .TO. '\<elsif\>' .TO. '\<else\>'

" Engage debugging mode to overcome bug in matchpairs matching...
let b:match_debug = 1

" Work out what the comment character is, by filetype...
echo &ft
autocmd FileType           javascript,typescript          let b:cmt = exists('b:cmt') ? b:cmt : '//'
autocmd FileType           Jenkinsfile                    let b:cmt = exists('b:cmt') ? b:cmt : '//'
autocmd FileType           *sh,awk,python,perl,perl6,ruby let b:cmt = exists('b:cmt') ? b:cmt : '#'
autocmd FileType           vim                            let b:cmt = exists('b:cmt') ? b:cmt : '"'
autocmd FileType           dosbatch                       let b:cmt = exists('b:cmt') ? b:cmt : 'REM '
autocmd BufNewFile,BufRead *.vim,.vimrc                   let b:cmt = exists('b:cmt') ? b:cmt : '"'
autocmd BufNewFile,BufRead *.p[lm],.t                     let b:cmt = exists('b:cmt') ? b:cmt : '#'
autocmd BufNewFile,BufRead *.bat                          let b:cmt = exists('b:cmt') ? b:cmt : 'REM '
autocmd BufNewFile,BufRead *.js,*.ts                      let b:cmt = exists('b:cmt') ? b:cmt : '//'
autocmd BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp,*.java     let b:cmt = exists('b:cmt') ? b:cmt : '//'
autocmd BufNewFile,BufRead *                              let b:cmt = exists('b:cmt') ? b:cmt : '#'

" Work out whether the line has a comment then reverse that condition...
function! ToggleComment ()
  " What's the comment character???
  let comment_char = exists('b:cmt') ? b:cmt : '#'

  " Grab the line and work out whether it's commented...
  let currline = getline(".")

  " If so, remove it and rewrite the line...
  if currline =~ '^\s*' . comment_char
    let repline = substitute(currline, '^\s*' . comment_char, "", "")
    call setline(".", repline)

    " Otherwise, insert it...
  else
    let repline = substitute(currline, '^', comment_char, "")
    call setline(".", repline)
  endif
endfunction

" Toggle comments down an entire visual selection of lines...
function! ToggleBlock () range
  " What's the comment character???
  let comment_char = exists('b:cmt') ? b:cmt : '#'

  " Start at the first line...
  let linenum = a:firstline

  " Get all the lines, and decide their comment state by examining the first...
  let currline = getline(a:firstline, a:lastline)
  if currline[0] =~ '^\s*' . comment_char
    " If the first line is commented, decomment all...
    for line in currline
      let repline = substitute(line, '^\s*' . comment_char, "", "")
      call setline(linenum, repline)
      let linenum += 1
    endfor
  else
    " Otherwise, encomment all...
    for line in currline
      let repline = substitute(line, '^\('. comment_char . '\)\?', comment_char, "")
      call setline(linenum, repline)
      let linenum += 1
    endfor
  endif
 endfunction

 " Set up the relevant mappings
 nmap <silent> # :call ToggleComment()<CR>j0
 vmap <silent> # :call ToggleBlock()<CR>

 "=====[ Auto-setup for template scripts and modules ]===========
 augroup Perl_Setup
  autocmd!
  autocmd BufNewFile *.p[lm] 0r !file_template <afile>
  autocmd BufNewFile *.p[lm] /^[ \t]*[#].*implementation[ \t]\+here/

  autocmd BufNewFile pom.xml 0r !file_template <afile>
  autocmd BufNewFile pom.xml /#HERE/

  autocmd BufNewFile *.sh 0r !file_template <afile>
  autocmd BufNewFile *.sh /here/
 augroup END

function! Perltidy_diff ()
  " Work out what the tidied file will be called...
  let perl_file = expand( '%' )
  let tidy_file = perl_file . '.tdy'

  call system( 'perltidy -nst ' . perl_file . ' -o ' . tidy_file )

  " Add the diff to the right of the current window...
  set splitright
  exe ":vertical diffsplit " . tidy_file

  " Clean up the tidied version...
  call delete(tidy_file)
endfunction

function! BuffDiff ()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

function! GitDiff ()
  let filetype=&ft
  let cmd = '%!git show :0:./' . expand('%')
  diffthis
  vnew | exe cmd
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
  diffthis
endfunction

"=====[ gitdiff ]===========================================================
nmap <silent> ;c  :call BuffDiff()<CR>
nmap <silent> ;cc :call GitDiff()<CR>

"====[ insert markers ]===================================================
nmap mm :call Marker()<CR>

function! Marker ()
  let comment_char = exists('b:cmt') ? b:cmt : '#'
  let currline = getline('.')
  let strClean = substitute(currline, '^\s*\(.\{-}\)\s*$', '\1', '')
  

  let marker = comment_char . '====[ ' . strClean . ' ]' . repeat('=', 51-len(strClean))

  let indx = line('.')
  call setline(indx, marker)
endfunction

"====[ block sort ]=========================================
function! SortBlock () range
  execute ":" . a:firstline . "," . a:lastline . " sort"
endfunction

vmap ;s :call SortBlock()<CR>

"====[ formatting ]=========================================
command! -nargs=1 PadTo :call PadLine(<q-args>)
function! PadLine (column) 
  " find the first column position with a whitespace
  " pad out from there
  let pos = virtcol('.')
  let currline = getline('.')
  while strcharpart(strpart(currline, pos- 1), 0, 1) != ' '
    if pos == len(currline)
      break
    endif
    let pos += 1
  endwhile

  let strEnd = strpart(currline, pos-1)
  let strClean = substitute(strEnd, '^\s*\(.\{-}\)\s*$', '\1', '')

  call setline('.', strpart(currline, 0, pos-1) . repeat(' ', a:column-pos) . strClean) 
endfunction

"====[ Argo Workflow ]======================================
nmap ;as :ArgoSubmit<CR>
nmap ;al :ArgoLint<CR>
nmap ;an :ArgoNewWorkflow<CR>

"====[ Tagbar ]=============================================
nmap <F12> :TagbarToggle<CR>


"====[ ALE Mapping ]========================================
nmap <F11>             :ALEDetail<CR>
nmap <silent> <C-Up>   :ALEPrevious<CR>
nmap <silent> <C-Down> :ALENext<CR>

let g:indentLine_enabled = 0
let g:airline_powerline_fonts = 1

runtime plugin/style.vim
