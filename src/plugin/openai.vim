vim9script

if exists("g:loaded_openai")
  finish
endif
g:loaded_openai = 1

var model = 'code-davinci-002'  # The model used to generate the completion
var temperature = 0             # Controls randomness; lower = more deterministic
var maxTokens = 64              # max number of tokens to generate
var freqPenalty = 0             # penalize new tokens based on their existing frequency in the text so far
var presencePenalty = 0         # penalize new tokens based on whether they appear in the text so far
var bestOf = 1                  # generate multiple complettions but on return the best
var doEcho = 'false'            # echo the prompt back in the response
var topP = 1                    # nucleus sampling; 0.1 means only the top 10% are considered
var stopString = '```'          # sequences where the API will stop generating further tokens

const API_ENDPOINT = 'https://api.openai.com/v1/engines/' .. model .. '/completions'
const TYPE_MAP = {
  'sh': 'bash',
}


noremap           <F9>  :call ExplainLine(0)<CR>
noremap  <silent> <F10> :call CreateNewFunction(0)<CR>
vnoremap <silent> <F10> :<c-u>call CreateNewFunction(1)<CR>

def g:ExplainLine(isVisual: bool): void
  var text = getline('.')

  const fType = get(TYPE_MAP, &filetype, &filetype)
  var encoded = substitute(trim(text), '\\', '\\\\', 'g')
  encoded = substitute(encoded, '"', '\\"', 'g')

  const prompt = b:cmt .. " Explain what the following " .. fType .. " code does.\\n" .. encoded

  const cmd = "curl -X POST -sSL -H 'Content-Type: application/json' -H 'Authorization: Bearer "
                .. $OPENAI_API_KEY
                .. "' -d '{"
                .. "\"echo\": "              .. doEcho          .. ","
                .. "\"frequency_penalty\": " .. freqPenalty     .. ","
                .. "\"max_tokens\": "        .. maxTokens       .. ","
                .. "\"presence_penalty\": "  .. presencePenalty .. ","
                .. "\"temperature\": "       .. temperature     .. ","
                .. "\"prompt\":\""           .. trim(prompt)    .. "\""
                .. "}' "
                .. API_ENDPOINT

#  echo "[" .. cmd .. "]"

  var lpos = getpos('.')[1]

  echo "Explaining..."
  var output = trim(system(cmd))
#  echo output
  output = trim(system("echo '" .. output .. "' | jq --raw-output '.choices[0].text'"))
  call append(lpos - 1, split(output, "\n"))
enddef

def g:CreateNewFunction(isVisual: bool): void

  if ! $OPENAI_API_KEY
    echoerr "OPENAI_API_KEY has not been specified"
    return
  endif

  var text = GetText(isVisual)
  const prompt = "Write a " .. get(TYPE_MAP, &filetype, &filetype) .. " function to " .. text

  const cmd = "curl -X POST -sSL -H 'Content-Type: application/json' -H 'Authorization: Bearer "
                .. $OPENAI_API_KEY
                .. "' -d '{"
                .. "\"echo\": "              .. doEcho          .. ","
                .. "\"frequency_penalty\": " .. freqPenalty     .. ","
                .. "\"max_tokens\": "        .. maxTokens       .. ","
                .. "\"presence_penalty\": "  .. presencePenalty .. ","
                .. "\"temperature\": "       .. temperature     .. ","
                .. "\"prompt\":\""           .. trim(prompt)    .. "\""
                .. "}' "
                .. API_ENDPOINT

#  echo "[" .. cmd .. "]"

  var lpos = getpos('.')[1]
  if isVisual
    lpos = getpos("'>")[1]
  endif

  echo "Generating..."
  var output = trim(system(cmd))
  output = trim(system("echo '" .. output .. "' | jq --raw-output '.choices[0].text'"))
  call append(lpos, split(output, "\n"))
enddef

def GetText(isVisual: bool): string
  var lines = [getline('.')]
  if isVisual
    var [line_start, column_start] = getpos("'<")[1 : 2]
    var [line_end, column_end] = getpos("'>")[1 : 2]
    lines = getline(line_start, line_end)
  endif

  if len(lines) == 0
     return ''
  endif

  var retval = []
  for ln in lines
    add(retval, substitute(ln, '^\s*' .. b:cmt .. '\s*', '', ''))
  endfor

  return join(retval, ' ')
enddef

defcompile
