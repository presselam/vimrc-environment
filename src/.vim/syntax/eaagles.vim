" Vim syntax file
" Language:   Eaagles Description Language

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

command -nargs=+ HiLink hi def link <args>
hi clear eldIdentifier
HiLink eldIdentifier Statement
hi clear eldSlotID   
HiLink eldSlotID     Statement
hi clear eldKeyword 
HiLink eldKeyword    Constant
hi clear eldComment
HiLink eldComment    Comment
hi clear eldObject
HiLink eldObject     Special
hi clear eldValue
HiLink eldValue     Normal
hi clear eldList
HiLink eldList     Normal
delcommand HiLink

syn keyword eldKeyword TRUE true false FALSE

syn match eldObject       "[a-zA-Z]\+" contained
syn match eldSlotID       "[a-zA-Z]\+:"
syn match eldComment      "//.*"
syn match eldStartObject  "^\s\*(.\*" contains=eldObject skipwhite 
syn match eldValue        ":\s\+[a-zA-Z0-9~!@#$%^&*\-_+=<>?/]\+"
syn region eldList matchgroup=eldList start="\[" end="\]" 
syn region eldList matchgroup=eldList start="\"" end="\"" 
syn region eldList matchgroup=eldList start="(" end=")"  oneline



syn region arglistfold start="{" end="}" fold transparent


let b:current_syntax = "eaagles"
let &cpo = s:cpo_save
unlet s:cpo_save
