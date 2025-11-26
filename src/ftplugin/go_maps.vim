if exists("b:did_go_maps")
  finish
endif
let b:did_go_maps = 1


"====[ Ale Fixer ]==========================================
let b:ale_fixers = ['gofmt']
let b:ale_fix_on_save = 1
