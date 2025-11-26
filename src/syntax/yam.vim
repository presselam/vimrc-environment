" Vim syntax file
" Language: Celestia Star Catalogs
" Maintainer: Kevin Lauder
" Latest Revision: 26 April 2008

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "yam"

hi def link yam_keyword  Keyword
hi def link yam_comment  Comment
hi def link yam_special  Special
hi def link yam_string   String
hi def link yam_label    Function

hi Function cterm=bold

syn keyword yam_keyword close call return kill  wait if dis ena pattern put sleep lput goto gosub set obey setn

syn match yam_special '\\t\|\\n\|\\r'

syn match yam_comment ':.*'

syn match yam_string '\".*\"'

syn match yam_label '^\w\+:\?$'
