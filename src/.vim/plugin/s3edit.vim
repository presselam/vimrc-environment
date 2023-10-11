vim9script

if exists("g:loaded_s3edit")
  finish
endif
g:loaded_s3edit = 1

const tmpPrefix = '/tmp/s3edit'
var s3uri     = ''
var bufferFile = ''
var bufferName   = ''

augroup S3EditGlobal
  autocmd!
  autocmd BufEnter s3://* :call S3Edit()
augroup END

command! -nargs=1 SEdit :call S3Edit(<q-args>)
def g:S3Edit(uri: string = expand('<afile>'))
  s3uri = uri

  # echom "s3uri[" .. uri .. "]"
 
  final parts = split(s3uri, '/')
  bufferName = parts[-1]
  bufferFile = tmpPrefix .. '/' .. bufferName

  final rc = system('aws s3 cp ' .. s3uri .. ' ' .. bufferFile)
  # echom "s3-fetch: [" .. rc .. "]"

  var buffy = bufwinnr(bufferName)
  var bufId = bufnr(bufferName, 1)

  # Only open a new buffer if it's not visible
  if bufwinnr(bufferName) == -1
    bufload(bufId)
    setbufline(bufId, 1, ['some', 'text'])
  endif

  execute 'edit ' .. bufferFile

enddef

command! -nargs=0 SWrite :call S3Write()
def g:S3Write()
  execute 'write'
  final rc = system('aws s3 cp ' .. bufferFile .. ' ' .. s3uri)
  #  echom "s3-write: [" .. rc .. "]"
enddef
