vim9script

if exists("g:loaded_trackperlvars")
  finish
endif

g:loaded_trackperlvars = 1

augroup TrackVarGlobal
  autocmd!
  autocmd BufEnter * call TPV_setup()
  autocmd WinEnter * call TPV_setup()
  autocmd BufLeave * call TPV_teardown()
augroup END
 
# Set up initial highlight groups (unless already set)...
highlight default      TRACK_PERL_VAR             ctermfg=blue                cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_QUESTION    ctermfg=white                cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_LOCKED      ctermfg=cyan   ctermbg=blue  cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_UNDECLARED  ctermfg=red                  cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_UNUSED      ctermfg=cyan                 cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default      TRACK_PERL_VAR_BUILTIN     ctermfg=magenta              cterm=bold   gui=NONE guifg=#000000 guibg=#ffffff
highlight default link TRACK_PERL_VAR_ACTIVE      TRACK_PERL_VAR

# Select an unlikely match number (e.g. the Neighbours of the Beast)...
const match_id = 664668

# This tracks whether plugin is displaying a message...
var   displaying_message = 0

# Track last highlighted var for vmaps...
var prev_sigil   = ""
var prev_varname = ""

const MATCH_VAR_PAT = join([
\     '\(',
\         '[@%]\zs[$]',
\     '\|',
\         '[@%]',
\     '\|',
\         '[$][#]\?',
\     '\)',
\     '\s*',
\     '\(',
\         '\d\+',
\     '\|',
\         '\K\k*',
\     '\|',
\         '\^\K',
\     '\|',
\         '[{]\d\+[}]',
\     '\|',
\         '[{]\^\h\w*[}]',
\     '\|',
\         '[{][$]\@!\K\k*[}]',
\     '\|',
\         '[{][[:punct:]][}]',
\     '\|',
\         '[{]\@![[:punct:]]',
\     '\)'
\ ], '')

const ORDINAL = { '1': 'st', '2': 'nd', '3': 'rd' }

const PUNCT_VAR_DESC = {
  '$!':                     'Status from most recent system call (including I/O)',
  '$"':                     'List separator for array interpolation',
  '$#':                     'Output number format [deprecated: use printf() instead]',
  '$$':                     'Process ID',
  '$%':                     'Page number of the current output page',
  '$&':                     'Most recent regex match string',
  "$'":                     'String following most recent regex match',
  '$(':                     'Real group ID of the current process',
  '$)':                     'Effective group ID of the current process',
  '$*':                     'Regex multiline matching flag [removed: use /m instead]',
  '$,':                     'Output field separator for print() and say()',
  '$-':                     'Number of lines remaining in current output page',
  '$.':                     'Line number of last input line',
  '$/':                     'Input record separator (end-of-line marker on inputs)',
  '$0':                     'Program name',
  '$1':                     'First capture group from most recent regex match',
  '$2':                     'Second capture group from most recent regex match',
  '$3':                     'Third capture group from most recent regex match',
  '$4':                     'Fourth capture group from most recent regex match',
  '$5':                     'Fifth capture group from most recent regex match',
  '$6':                     'Sixth capture group from most recent regex match',
  '$7':                     'Seventh capture group from most recent regex match',
  '$8':                     'Eighth capture group from most recent regex match',
  '$9':                     'Ninth capture group from most recent regex match',
  '$+':                     'Final capture group of most recent regex match',
  '$:':                     'Break characters for format() lines',
  '$;':                     'Hash subscript separator for key concatenation',
  '$<':                     'Real uid of the current process',
  '$=':                     'Page length of selected output channel',
  '$>':                     'Effective uid of the current process',
  '$?':                     'Status from most recent system call (including I/O)',
  '$@':                     'Current propagating exception',
  '$ARGV':                  'Name of file being read by readline() or <>',
  '$[':                     'Array index origin [deprecated]',
  '$\':                     'Output record separator (appended to every print())',
  '$]':                     'Perl interpreter version [deprecated: use $^V]',
  '$^':                     'Name of top-of-page format for selected output channel',
  '$^A':                    'Accumulator for format() lines',
  '$^C':                    'Is the program still compiling?',
  '$^D':                    'Debugging flags',
  '$^E':                    'O/S specific error information',
  '$^F':                    'Maximum system file descriptor',
  '$^H':                    'Internal compile-time lexical hints',
  '$^I':                    'In-place editing value',
  '$^L':                    'Form-feed sequence for format() pages',
  '$^M':                    'Emergency memory pool',
  '$^N':                    'Most recent capture group (within regex)',
  '$^O':                    'Operating system name',
  '$^P':                    'Internal debugging flags',
  '$^R':                    'Result of last successful code block (within regex)',
  '$^S':                    'Current eval() state',
  '$^T':                    'Program start time',
  '$^V':                    'Perl interpreter version',
  '$^W':                    'Global warning flags',
  '$^X':                    'Perl interpreter invocation name',
  '$_':                     'Topic variable: default argument for matches and many builtins',
  '$`':                     'String preceding most recent regex match',
  '${^CHILD_ERROR_NATIVE}': 'Native status from most recent system call',
  '${^ENCODING}':           'Encode object for source conversion to Unicode',
  '${^GLOBAL_PHASE}':       'Current interpreter phase',
  '${^MATCH}':              'Most recent regex match string (under /p)',
  '${^OPEN}':               'PerlIO I/O layers',
  '${^POSTMATCH}':          'String following most recent regex match (under /p)',
  '${^PREMATCH}':           'String preceding most recent regex match (under /p)',
  '${^RE_DEBUG_FLAGS}':     'Regex debugging flags',
  '${^RE_TRIE_MAXBUF}':     'Cache limit on regex optimizations',
  '${^TAINT}':              'Taint mode',
  '${^UNICODE}':            'Unicode settings',
  '${^UTF8CACHE}':          'Internal UTF-8 offset caching controls',
  '${^UTF8LOCALE}':         'UTF-8 locale',
  '${^WARNING_BITS}':       'Lexical warning flags',
  '${^WIN32_SLOPPY_STAT}':  'Use non-opening stat() under Windows',
  '$|':                     'Autoflush status of selected output filehandle',
  '$~':                     'Name of format for selected output channel',
  '%!':                     'Status of all possible errors from most recent system call',
  '%+':                     'Named captures of most recent regex match (as strings)',
  '%-':                     'Named captures of most recent regex match (as arrays of strings)',
  '%ENV':                   'The current shell environment',
  '%INC':                   'Filepaths of loaded modules',
  '%SIG':                   'Signal handlers',
  '%^H':                    'Lexical hints hash',
  '@+':                     'Offsets of ends of capture groups of most recent regex match',
  '@-':                     'Offsets of starts of capture groups of most recent regex match',
  '@ARGV':                  'Command line arguments',
  '@F':                     'Fields of the current input line (under autosplit mode)',
  '@INC':                   'Search path for loading modules',
  '@_':                     'Subroutine arguments',
}







def TPV_setup()
  # Only for perl files
  if &filetype == 'perl' || expand('%:e') =~ '^\%(\.p[lm]\|\.t\)$'

    # Tracking can be locked by setting this variable
    if !exists('b:track_perl_var_locked')
      b:track_perl_var_locked = 0
    endif

   # Set up autocommands ...
   augroup TrackVarBuffer
      autocmd!
      autocmd CursorMoved  <buffer> call TPV_track_perl_var()
      autocmd CursorMovedI <buffer> call TPV_track_perl_var()
   augroup END


    # Remember how * was setup (if it was) and change it
    b:old_star_map = maparg('*')
    nmap <special> <buffer><silent> *  :let @/ = <SID>TPV_locate_perl_var()<CR>

    # cv => change variable...
    nmap <special> <buffer> cv :call <SID>TPV_rename_perl_var('normal')<CR>
    vmap <special> <buffer> cv :call <SID>TPV_rename_perl_var('normal')<CR>gv

    # gd => goto definiton...
    nmap <special> <buffer><silent> gd :let @/ = <SID>TPV_locate_perl_var_decl()<CR>

    # tt => toggle tracking...
    nmap <special> <buffer><silent> tt :let b:track_perl_var_locked = ! b:track_perl_var_locked<CR>:call TPV_track_perl_var()<CR>

    # Adjust keywords to cover sigils and qualifiers...
    setlocal iskeyword+=$
    setlocal iskeyword+=%
    setlocal iskeyword+=@-@
    setlocal iskeyword+=:
    setlocal iskeyword-=,

    # Restore any frozen tracking...
    if b:track_perl_var_locked
      highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR_LOCKED
      try
        call matchadd('TRACK_PERL_VAR_ACTIVE', b:track_perl_var_locked_pat, 1000, match_id)
      catch /./
      endtry
    endif

  endif
enddef

def TPV_teardown()
  echo "teardown"
enddef


def TPV_track_perl_var()
  # Is tracking locked???
  highlight TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
  if b:track_perl_var_locked
    highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR_LOCKED
    return
  else
    highlight! link TRACK_PERL_VAR_ACTIVE  TRACK_PERL_VAR
  endif

  # Remove previous highlighting...
  try
    call matchdelete(match_id)
  catch
  endtry

  # Locate a var under cursor...
  var cursline = getline('.')
  var curscol  = col('.')

#  echo "[" .. cursline .. "][" .. curscol .. "]"
  var varparts = matchlist(cursline, '\%<' .. (curscol + 1) .. 'c' .. MATCH_VAR_PAT .. '\%>' .. curscol .. 'c\s*\([[{]\)\?')

  # Short-circuit if nothing to track...
#  echo varparts
  if empty(varparts)
    if displaying_message
      echo ""
      displaying_message = 0
    endif
    prev_sigil   = ""
    prev_varname = ""
    return
  endif
 
  # Otherwise, extract components of variable...
  var sigil   = get(varparts, 1)
  var varname = escape(substitute(get(varparts, 2), '^{\([^^].*\)}$', '\1', 'g'), '\\')
  var bracket = get(varparts, 3, '')

  # Do we need to bound the varname???
  var boundary = varname =~ '\w$' ? '\>' : ''

  var curs_var = ''

  # Handle arrays: @array, $array[...], $#array...
  if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
    sigil = '@'
    curs_var = '\C\%('
                 .. '[$%]\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\%(\_s*[[]\)\@=\|'
                 .. '[$]#\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\|'
                 ..  '[@]\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\%(\_s*[{]\)\@!'
                 .. '\)'

  # Handle hashes: %hash, $hash{...}, @hash{...}...
  elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
    sigil = '%'
    curs_var = '\C\%('
                 .. '[$@]\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\%(\_s*[{]\)\@=\|'
                 ..  '[%]\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\%(\_s*[[]\)\@!'
                 .. '\)'

  # Handle scalars: $scalar
  else
    sigil = '$'
    curs_var = '\C[$]\_s*\%(' .. varname .. boundary .. '\|{' .. varname .. '}\)\%(\_s*[[{]\)\@!'
  endif

  # Special highlighting and descriptions for builtins...
  var desc = get(PUNCT_VAR_DESC, sigil .. varname,
                 varname =~ '^\d\+$'
                   ? varname .. get(ORDINAL, varname[-1 :], 'th') .. ' capture group of most recent regex match'
                   : ''
             )

  if len(desc) > 0
    highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
    highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_BUILTIN

    echohl TRACK_PERL_VAR_BUILTIN
    echo sigil .. varname .. ': ' .. desc
    echohl None
    displaying_message = 1

  # Special highlighting for undeclared variables...
  elseif varname !~ ':' && !search('^[^#]*\%(my\|our\|state\).*' .. sigil .. varname .. '\%(\_$\|\W\@=\)', 'Wbnc')
    highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
    highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_UNDECLARED
    echohl TRACK_PERL_VAR_UNDECLARED
    echo 'Undeclared variable'
    echohl None
    displaying_message = 1

  # Special highlighting for singleton variables...
  elseif varname !~ ':' && searchpos('\<' .. curs_var, 'wn') == searchpos('\<' .. curs_var, 'bcwn')
    highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
    highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR_UNUSED
    echohl TRACK_PERL_VAR_UNUSED
    echo 'Unused variable'
    echohl None
    displaying_message = 1

  # Special highlighting for ordinary variables...
  else
    highlight!      TRACK_PERL_VAR_ACTIVE   cterm=NONE gui=NONE guifg=NONE guibg=NONE
    highlight! link TRACK_PERL_VAR_ACTIVE   TRACK_PERL_VAR

    # Does this var have a descriptive comment???
    var new_message = 0
    var decl_pat = '\C^[^#]*\%(my\|our\|state\)\%(\s*([^)]*\|\s*\)\zs' .. sigil .. varname .. '\%(\_$\|\W\)\@='
    var decl_line_num = search(decl_pat, 'Wcbn')
    if decl_line_num > 0   # Ugly nested if's to minimize computation per cursor move...
       var decl_line = getline(decl_line_num)
       if decl_line =~ '\s#\s'
         decl_line = substitute(decl_line, '.*\s#\s', sigil .. varname .. ': ', '')
         if len(decl_line) > 0
           echohl TRACK_PERL_VAR
           echo decl_line
           echohl None
           displaying_message = 1
           new_message = 1
         endif
       endif
    endif

    if displaying_message && !new_message
       echo ""
       displaying_message = 0
    endif
  endif

  # Set up the match for variables...
  b:track_perl_var_locked_pat = '\<' .. curs_var .. '\%(\_$\|\W\@=\)'
  try
    call matchadd('TRACK_PERL_VAR_ACTIVE', b:track_perl_var_locked_pat, 1000, match_id)
  catch /./
  endtry

  # Remember the variable...
  prev_sigil   = sigil
  prev_varname = varname

enddef

def TPV_rename_perl_var(mode: string)
  # Grab the currently highlighted variable (if any)...
  var sigil   = prev_sigil
  var varname = prev_varname

  if empty(sigil)
    echohl WarningMsg
    echo "Nothing to rename (cursor is not on a variable)"
    echohl None
    return
  endif

  var curs_var = ''
  # Handle arrays: @array, $array[...], $#array...
  if sigil == '@'
     curs_var = '\C\%('
                   .. '[$%]\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\%(\_s*[[]\)\@=\|'
                   .. '[$]#\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\|'
                   ..  '[@]\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\%(\_s*[{]\)\@!'
                   .. '\)'

    # Handle hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%'
      curs_var = '\C\%('
                    .. '[$@]\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\%(\_s*[{]\)\@=\|'
                    ..  '[%]\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\%(\_s*[[]\)\@!'
                    .. '\)'

    # Handle scalars: $scalar
    else
      curs_var = '\C[$]\_s*\%(\zs' .. varname .. '\>\ze\|{\zs' .. varname .. '\ze}\)\%(\_s*[[{]\)\@!'
    endif

    # Request the new name...
    echohl TRACK_PERL_VAR_QUESTION
    var context = mode == 'normal' ? 'Globally' : 'Within visual selection'
    call inputsave()
    var new_varname = input(context .. ' rename variable ' .. sigil .. varname .. ' to: ' .. sigil)
    call inputrestore()
    echohl None
    if new_varname ==# varname || new_varname == ""
        echohl WarningMsg
        echo "Cancelled"
        echohl None
        return
    endif

    # Verify that it's safe...
    var check_new_var = substitute('\<' .. curs_var, varname, new_varname, 'g')
    if search(check_new_var, 'wnc')
        echohl TRACK_PERL_VAR_QUESTION
        echon "\rA variable named " .. sigil .. new_varname .. ' already exists. Proceed anyway? '
        echohl None
        var response = nr2char(getchar())
        echon response
        echo ""
        if response =~ '^[^Yy]'
            echohl WarningMsg
            echo "Cancelled"
            echohl None
            return
        endif
    endif

    # Apply the transformation...
    # var range = (mode == 'normal' ? '%' : a:firstline . ',' . a:lastline)
    exec ':%s/\<' .. curs_var .. '/' .. new_varname .. '/g'

    # Return to original position...
    normal ``

    # Circumvent the default gv after a vcv...
    if mode == 'visual'
        exec 'nmap <silent> gv  :nmap gv ' .. maparg('gv', 'n') .. '<CR>'
    endif
enddef

def TPV_locate_perl_var(): string
    # Locate a var under cursor...
    var cursline = getline('.')
    var curscol  = col('.')

    var varparts =
      matchlist(cursline, '\%<' .. (curscol + 1) .. 'c' .. MATCH_VAR_PAT .. '\%>' .. curscol .. 'c\s*\([[{]\)\?')

    # Revert to generic behaviour if not on a variable
    if empty(varparts)
      exec empty(b:old_star_map) ? b:old_star_map : 'normal! *'
      return @/
    endif

    # Otherwise, extract components of variable...
    var sigil    = get(varparts, 1)
    var varname  = substitute(get(varparts, 2), '^[{]\(.*\)[}]$', '\1', '')
    var bracket  = get(varparts, 3, '')
    var curs_var = ''

    
    # Handle arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
      sigil = '@'
      curs_var = '\C\%('
                   .. '[$%]\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\%(\_s*[[]\)\@=\|'
                   .. '[$]#\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\|'
                   ..  '[@]\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\%(\_s*[{]\)\@!'
                   .. '\)'

    # Handle hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
      sigil = '%'
      curs_var = '\C\%('
                   .. '[$@]\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\%(\_s*[{]\)\@=\|'
                   ..  '[%]\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\%(\_s*[[]\)\@!'
                   .. '\)'

    # Handle scalars: $scalar
    else
      sigil = '$'
      curs_var = '\C[$]\_s*\%(' .. varname .. '\>\ze\|{' .. varname .. '}\ze\)\%(\_s*[[{]\)\@!'
    endif

    # Finally, search forwards for the declaration and report the outcome...
    call search('\<' .. curs_var, 's')
    return curs_var
enddef


def TPV_locate_perl_var_decl(): string
    # Locate a var under cursor...
    var cursline = getline('.')
    var curscol  = col('.')

    var varparts =
      matchlist(cursline, '\%<' .. (curscol + 1) .. 'c' .. MATCH_VAR_PAT .. '\%>' .. curscol .. 'c\s*\([[{]\)\?')

    # Warn if nothing to locate...
    if empty(varparts)
        echohl WarningMsg
        echo "Can't locate a declaration (cursor is not on a variable)"
        echohl None
        return @/
    endif

    # Otherwise, extract components of variable...
    var sigil   = get(varparts, 1)
    var varname = substitute(get(varparts, 2), '^[{]\(.*\)[}]$', '\1', '')
    var bracket = get(varparts, 3, '')

    # Identify arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
        sigil = '@'

    # Identify hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
        sigil = '%'

    # Identify scalars: $scalar
    else
        sigil = '$'
    endif

    # Ignore builtins...
    if len( get(PUNCT_VAR_DESC, sigil .. varname, '') ) > 0  ||
       len( get(PUNCT_VAR_DESC, sigil .. '{' .. varname .. '}', '') )
        echohl TRACK_PERL_VAR_BUILTIN
        echo "Builtins don't have declarations"
        echohl None
        return @/
    endif

    # Otherwise search backwards for the declaration and report the outcome...
    var decl_pat = '\C^[^#]*\%(my\|our\|state\)\%(\s*([^)]*\|\s*\)\zs' .. sigil .. varname .. '\%(\_$\|\W\)\@='
    if !search(decl_pat, 'Wbs')
        echohl WarningMsg
        echo "Can't find a declaration before this point"
        echohl None
        return @/
    endif

    return decl_pat
enddef

