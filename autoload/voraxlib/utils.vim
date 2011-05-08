" Description: Various miscellaneous functions needed by VoraX.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo=&cpo
set cpo-=C

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
endfunction

let &cpo=s:cpo
unlet s:cpo

