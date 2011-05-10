" Description: Various miscellaneous functions needed by VoraX.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo=&cpo
set cpo-=C

" How statements are sepparated
let s:sql_delimitator_pattern = ';\|^\s*\/\s*$'
let s:sql_strip_comments_pattern = '((\s*\/\*[^*\/]*\*\/\s*)|(\s*--[^\n]*\n\s*)|(\s*\r?\n))*'

" Display a warning message.
function! voraxlib#utils#Warn(text)
  echohl WarningMsg
  echo a:text
  echohl Normal
endfunction

" Escape the provided text for a literal regexp match. This function always
" assumes that the regexp is used in the magic mode.
function! voraxlib#utils#LiteralRegexp(text)
  return escape(a:text, '^$.*\[]~')
endfunction

" Sort the provided list but eliminates the duplicates. Optionaly, a
" comparator may be provided. The sorted list elements are always converted to
" strings.
function! voraxlib#utils#SortUnique(list, ...)
  let dictionary = {}
  for i in a:list
    execute "let dictionary[ '" . i . "' ] = ''"
  endfor
  let result = []
  if ( exists( 'a:1' ) )
    let result = sort( keys( dictionary ), a:1 )
  else
    let result = sort( keys( dictionary ) )
  endif
  return result
endfunction

" Flatten the provided list.
function! voraxlib#utils#FlattenList(list)
  ruby VIM::command(%!return #{Vorax::VimUtils.to_vim(VIM::evaluate('a:list').flatten)}!)
endfunction

" Add the provided item to a:list only if that item is not already in the list
function! voraxlib#utils#AddUnique(list, item)
  if index(a:list, a:item) == -1
    call add(a:list, a:item)
  endif
endfunction

" Prompt the user for something and check the inputed value. The a:askobj is a
" dictionary with the following structure:
" { 'prompt' : '<your_msg>',
"   'check'  : [{'regexp' : '<your regexp check>', 'errmsg' : '<your error message in case the check failed>'} ... ]
" }
function! voraxlib#utils#Ask(askobj)
  let valid = 0
  let retval = ''
  while !valid
    let retval = input(a:askobj.prompt)
    for checkobj in a:askobj.check
      if retval !~ checkobj.regexp
        let valid = 0
        call voraxlib#utils#Warn(checkobj.errmsg)
        echo ''
        break
      else
      	let valid = 1
      endif
    endfor
  endwhile
  return retval
endfunction

" Prompt the user to pick an option. The provided a:prompt is displayed first
" and a list of choices under. The a:choices should be an array of strings and
" each item should provide an accelerator key as '(<accelerator>)'. For
" example: ['(Y)es', '(N)o']. The acelerator is case insensitive. This
" function returns the accelerator key corresponding to the picked choice.
" Obviously, the accelerator should be unique within the provided choices.
function! voraxlib#utils#PickOption(prompt, choices)
  echo a:prompt
  let valid_keys = map(copy(a:choices), 'substitute(v:val, ''^.*(\(.\)).*$'', ''\1'', '''')')
  for choice in a:choices
    echo '  ' . choice
  endfor
  echo ''
  let valid_key = 0
  while !valid_key 
    let char = getchar()
    if char == 27
    	" exit
    	let key = ''
    	break
    endif
    let key = nr2char(char)
    for k in valid_keys
      if key =~? '^' . voraxlib#utils#LiteralRegexp(k) . '$'
        let valid_key = 1
        break
      else
      	let valid_key = 0
      endif
    endfor
  endwhile
  return key
endfunction

" Get the currently selected block.
function! voraxlib#utils#SelectedBlock() range
    let save = @"
    silent normal gvy
    let vis_cmd = @"
    let @" = save
    return vis_cmd
endfunction 

function! voraxlib#utils#SqlUnderCursor()
  " find the start
endfunction

" Highlights the provided range
function! voraxlib#utils#HighlightRange(hi_group, start_l, start_c, end_l, end_c)
  " highlight the first line
  if a:end_l - a:start_l > 0
    " the statement spans multiple lines
    let cmd = 'match ' . hi_group . ' /\%' . a:start_l . 'l' . '\%>' . (a:start_c - 1) . 'c' .
          \ '\|\%>' . a:start_l . 'l' . '\%<' . a:end_l . 'l.' .
          \ '\|\%' . a:end_l . 'l' . '\%<' . (a:end_c + 1) . 'c./'
  else
    " the statement is on one line
    let cmd = 'match ' . hi_group . ' /\%' . a:start_l . 'l' . '\%>' . (a:start_c - 1) . 'c' .
          \ '\%<' . (a:end_c + 1) . 'c./'
  endif
  exe cmd
endfunction

" Get the start of the current statement. If a:move is 1 then the cursor is
" moved to the beginning of the statement. The return value is an [line, col] array.
" This function relies to a valid sql syntax applied. If the syntax for the
" current buffer is not 'sql' then the execution is aborted and an exception
" is raised.
function! voraxlib#utils#GetStartOfCurrentSql(move)
  if !exists('b:current_syntax') || b:current_syntax != 'sql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  if !a:move
    " if not move requested then save state
    let state = winsaveview()
  endif
  let [l, c] = [0, 0]
  while 1
    let [l, c] = searchpos(s:sql_delimitator_pattern, 'beW')  
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == ''
      break
    endif
  endwhile
  if [l, c] != [0, 0]
    " not at the beginning of the buffer
    if c == col('$')-1 && l < line('$')
      " if at the end of the current line and not at the end of the buffer
      " set as the first position of the next line.
      let [l, c] = [l+1, 1]
    elseif c < col('$')-1
      " increment column just to skip the current delimitator
      let [l, c] = [l, c+1]
    endif
  else
  	let [l, c] = [1, 1]
  endif
  if !a:move
    " if not move requested then restore state
    call winrestview(state)
  else
    call setpos('.', [bufnr('%'), l, c, 0])
  endif
  return [l, c]
endfunction

" Get the end of the current statement. If a:move is 1 then the cursor is
" moved to the end of the statement. The return value is an [line, col] array.
" This function relies to a valid sql syntax applied. If the syntax for the
" current buffer is not 'sql' then the execution is aborted and an exception
" is raised.
function! voraxlib#utils#GetEndOfCurrentSql(move)
  if !exists('b:current_syntax') || b:current_syntax != 'sql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  if !a:move
    " if not move requested then save state
    let state = winsaveview()
  endif
  let [l, c] = [0, 0]
  let first = 1
  while 1
    let [l, c] = searchpos(s:sql_delimitator_pattern, 'W'. (first ? 'c' : ''))  
    let first = 0
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == ''
      break
    endif
  endwhile
  if [l, c] == [0, 0]
  	let [l, c] = [1, 1]
  endif
  if !a:move
    " if not move requested then restore state
    call winrestview(state)
  else
    call setpos('.', [bufnr('%'), l, c, 0])
  endif
  return [l, c]
endfunction

" Get rid of all SQL comments along with the empty lines from the beginning of the provided command.
function! voraxlib#utils#LTrimSqlComments(command)
  ruby <<EORC
  result = VIM::evaluate("a:command").gsub(/\A#{VIM::evaluate('s:sql_strip_comments_pattern')}/, '')
  VIM::command("return #{result.inspect}")
EORC
endfunction

" Get rid of all SQL comments along with the empty lines from the end of the provided command.
function! voraxlib#utils#RTrimSqlComments(command)
  ruby <<EORC
  result = VIM::evaluate("a:command").gsub(/#{VIM::evaluate('s:sql_strip_comments_pattern')}\Z/, '')
  VIM::command("return #{result.inspect}")
EORC
endfunction

" Get rid of sourrounding comments for the provided sql command.
function! voraxlib#utils#TrimSqlComments(command)
  return voraxlib#utils#RTrimSqlComments(voraxlib#utils#LTrimSqlComments(a:command))
endfunction

let &cpo=s:cpo
unlet s:cpo

