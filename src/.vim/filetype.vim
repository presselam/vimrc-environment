if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  au! BufRead,BufNewFile *.t            setfiletype perl
  au! BufRead,BufNewFile *.yam          setfiletype yam
  au! BufRead,BufNewFile *.p[lm]6       setfiletype perl6
  au! BufRead,BufNewFile .bash_*        setfiletype sh
  au! BufRead,BufNewFile *.ts           setfiletype typescript
  au! BufRead,BufNewFile *.shinc        setfiletype sh
  au! BufRead,BufNewFile .gitlab-ci.yml setfiletype yaml.gitlab
  au! BufRead,BufNewFile .*projrc       setfiletype yaml
  au! BufRead,BufNewFile *.sh.tpl       setfiletype tf.bash
augroup END


augroup filetypechmod
  au! BufWritePost *.p[lm]  :call setfperm(expand('%'), 'rwxr-xr-x')
  au! BufWritePost *.sh     :call setfperm(expand('%'), 'rwxr-xr-x')
augroup END
