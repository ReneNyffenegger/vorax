" Description: Various miscellaneous functions needed by VoraX.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_utils") 
 finish
endif

let g:_loaded_voraxlib_utils = 1
let s:cpo_save = &cpo
set cpo&vim

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" How statements are sepparated
let s:sql_delimitator_pattern = ';\|^\s*\/\s*$'
let s:plsql_end_marker = '\v\_s+end\_s*"?[^"]*"?\_s*;\_s*\_$'
let s:sql_strip_comments_pattern = '((\s*\/\*[^*\/]*\*\/\s*)|(\s*--[^\n]*((\n\s*)|\Z)))+'

" Display a warning message.
function! voraxlib#utils#Warn(text)"{{{
  echohl WarningMsg
  echo a:text
  echohl Normal
endfunction"}}}

" Escape the provided text for a literal regexp match. This function always
" assumes that the regexp is used in the magic mode.
function! voraxlib#utils#LiteralRegexp(text)"{{{
  return escape(a:text, '^$.*\[]~')
endfunction"}}}

" Sort the provided list but eliminates the duplicates. Optionaly, a
" comparator may be provided. The sorted list elements are always converted to
" strings.
function! voraxlib#utils#SortUnique(list, ...)"{{{
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
endfunction"}}}

" Add the provided item to a:list only if that item is not already in the list
function! voraxlib#utils#AddUnique(list, item)"{{{
  if index(a:list, a:item) == -1
    call add(a:list, a:item)
  endif
endfunction"}}}

" Prompt the user for something and check the inputed value. The a:askobj is a
" dictionary with the following structure:
" { 'prompt' : '<your_msg>',
"   'check'  : [{'regexp' : '<your regexp check>', 'errmsg' : '<your error message in case the check failed>'} ... ]
"   'default': '<your_default_value>'
" }
function! voraxlib#utils#Ask(askobj)"{{{
  let valid = 0
  let retval = ''
  while !valid
    let retval = input(a:askobj.prompt, (exists('a:askobj.default') ? a:askobj.default : ''))
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
endfunction"}}}

" Prompt the user to pick an option. The provided a:prompt is displayed first
" and a list of choices under. The a:choices should be an array of strings and
" each item should provide an accelerator key as '(<accelerator>)'. For
" example: ['(Y)es', '(N)o']. The acelerator is case insensitive. This
" function returns the accelerator key corresponding to the picked choice.
" Obviously, the accelerator should be unique within the provided choices.
function! voraxlib#utils#PickOption(prompt, choices)"{{{
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
endfunction"}}}

" Get the currently selected block.
function! voraxlib#utils#SelectedBlock() "{{{
  let reg_ = [@", getregtype('"')]
  let regA = [@a, getregtype('a')]
  if mode() =~# "[vV\<C-v>]"
    silent normal! "aygv
  else
    let pos = getpos('.')
    silent normal! gv"ay
    call setpos('.', pos)
  endif
  let text = @a
  call setreg('"', reg_[0], reg_[1])
  call setreg('a', regA[0], regA[1])
  return text
endfunction "}}}

" Visual select the provided range.
function! voraxlib#utils#SelectRange(start_l, start_c, end_l, end_c)
  let tail = a:end_c - a:start_c
  let lines = a:end_l - a:start_l
  if mode() !=# 'n'
    exec "normal \<Esc>"
  endif
  exec 'normal' a:start_l.'gg'.a:start_c.'|'.
        \ 'v'.(lines > 0 ? lines . 'j' : '').
        \ (tail > 0 ? tail . 'l' : '')
endfunction

" Visual select the current statement
function! voraxlib#utils#SelectCurrentStatement()
  let [start_l, start_c] = voraxlib#utils#GetStartOfCurrentSql(0)
  let [end_l, end_c] = voraxlib#utils#GetEndOfCurrentSql(0)
  let tail = end_c - start_c
  let lines = end_l - start_l
  if s:log.isDebugEnabled() | call s:log.debug('[start_l, start_c, end_l, end_c] = [' . start_l . ', ' . start_c . ', ' . end_l . ', ' . end_c . ']') | endif
  call voraxlib#utils#SelectRange(start_l, start_c, end_l, end_c)
endfunction

" Get the text within the provided range from the current buffer.
function! voraxlib#utils#GetTextFromRange(start_l, start_c, end_l, end_c)"{{{
  if a:start_l == a:end_l
    " one single line
    let text = strpart(getline(a:start_l), a:start_c - 1, (a:end_c - a:start_c + 1))
  else
  	" multiple lines
    let text = strpart(getline(a:start_l), a:start_c - 1) . "\n"
    for n in range(a:start_l + 1, a:end_l - 1)
      let text .= getline(n) . "\n"
    endfor
    let text .= strpart(getline(a:end_l), 0, a:end_c)
  endif
  return text
endfunction"}}}

" Highlights the provided range
function! voraxlib#utils#HighlightRange(hi_group, start_l, start_c, end_l, end_c)"{{{
  " highlight the first line
  if a:end_l - a:start_l > 0
    " the statement spans multiple lines
    let cmd = 'match ' . a:hi_group . ' /\%' . a:start_l . 'l' . '\%>' . (a:start_c - 1) . 'c' .
          \ '\|\%>' . a:start_l . 'l' . '\%<' . a:end_l . 'l.' .
          \ '\|\%' . a:end_l . 'l' . '\%<' . (a:end_c + 1) . 'c./'
  else
    " the statement is on one line
    let cmd = 'match ' . a:hi_group . ' /\%' . a:start_l . 'l' . '\%>' . (a:start_c - 1) . 'c' .
          \ '\%<' . (a:end_c + 1) . 'c./'
  endif
  exe cmd
endfunction"}}}

" Get the start of the current statement. If a:move is 1 then the cursor is
" moved to the beginning of the statement. The return value is an [line, col] array.
" This function relies to a valid sql syntax applied. If the syntax for the
" current buffer is not 'sql' then the execution is aborted and an exception
" is raised.
function! voraxlib#utils#GetStartOfCurrentSql(move)"{{{
  if !exists('b:current_syntax') || b:current_syntax != 'sql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  if !a:move
    " if not move requested then save state
    let state = winsaveview()
    " ignore events
    let _eventignore = &eventignore
    set eventignore=all
  endif
  let [l, c] = [0, 0]
  while 1
    let [l, c] = searchpos(s:sql_delimitator_pattern, 'beW')  
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == ''
      " exit if the delimitator is not within a special highlight group
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
    " restore events
    let &eventignore = _eventignore
  else
    call setpos('.', [bufnr('%'), l, c, 0])
  endif
  return [l, c]
endfunction"}}}

" Get the end of the current statement. If a:move is 1 then the cursor is
" moved to the end of the statement. The return value is an [line, col] array.
" This function relies to a valid sql syntax applied. If the syntax for the
" current buffer is not 'sql' then the execution is aborted and an exception
" is raised.
function! voraxlib#utils#GetEndOfCurrentSql(move)"{{{
  if !exists('b:current_syntax') || b:current_syntax != 'sql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  if !a:move
    " if not move requested then save state
    let state = winsaveview()
    " ignore events
    let _eventignore = &eventignore
    set eventignore=all
  endif
  let [l, c] = [0, 0]
  let first = 1
  while 1
    let [l, c] = searchpos(s:sql_delimitator_pattern, 'W'. (first ? 'c' : ''))  
    let first = 0
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == ''
      " exit if the delimitator is not within a special highlight group
      break
    endif
  endwhile
  if [l, c] == [0, 0]
  	let [l, c] = [line('$'), len(getline('$'))]
  endif
  if !a:move
    " if not move requested then restore state
    call winrestview(state)
    " restore events
    let &eventignore = _eventignore
  else
    call setpos('.', [bufnr('%'), l, c, 0])
  endif
  return [l, c]
endfunction"}}}

" Get rid of all SQL comments along with the empty lines from the beginning of the provided command.
function! voraxlib#utils#LTrimSqlComments(command)"{{{
  ruby <<EORC
  result = VIM::evaluate("a:command").gsub(/\A#{VIM::evaluate('s:sql_strip_comments_pattern')}/, '').gsub(/\A(\s*\r?\n)*/, '')
  VIM::command("return #{result.inspect}")
EORC
endfunction"}}}

" Get rid of all SQL comments along with the empty lines from the end of the provided command.
function! voraxlib#utils#RTrimSqlComments(command)"{{{
  ruby <<EORC
  result = VIM::evaluate("a:command").gsub(/#{VIM::evaluate('s:sql_strip_comments_pattern')}\Z/, '').gsub(/(\s*\r?\n)*\Z/, '')
  VIM::command("return #{result.inspect}")
EORC
endfunction"}}}

" Get rid of sourrounding comments for the provided sql command.
function! voraxlib#utils#TrimSqlComments(command)"{{{
  return voraxlib#utils#RTrimSqlComments(voraxlib#utils#LTrimSqlComments(a:command))
endfunction"}}}

" Get rid of all SQL comments which are replaced with whitespace in order to
" keep the meaning of the statement (e.g. select/*comment*/'abc' from dual; would
" be invalid if the comment is removed completelly)
function! voraxlib#utils#RemoveAllSqlComments(command)"{{{
  ruby <<EORC
  result = VIM::evaluate("a:command").gsub(/#{VIM::evaluate('s:sql_strip_comments_pattern')}/, "\n")
  VIM::command("return #{result.inspect}")
EORC
endfunction"}}}

" whenever or not the provided output contains oracle error messages
function! voraxlib#utils#HasErrors(output)"{{{
  return a:output =~ '^\(ORA\|SP[0-9]\?\|PLS\)-[0-9]\+'
endfunction"}}}

" whenever or not the current buffer is an oracle sql one.
function! voraxlib#utils#IsSqlOracleBuffer()"{{{
  " If g:sql_type_default is not initialized then assume Oracle.
  return (exists('g:sql_type_default') && g:sql_type_default == 'sqloracle' && &ft == 'sql' )
      \ || (!exists('g:sql_type_default'))
endfunction"}}}

" returns the a range of lines from the provide a:text starting from the
" line number given by a:start. The meaning of the optional param is how many
" lines to return counting from a:start. If this param is not provided then
" all lines till the end are returned.
function! voraxlib#utils#ExtractLines(text, start, ...)"{{{
  let retval = ''
  " find the start point
  let start_idx = -1
  for i in range((a:start > 0 ? a:start - 1 : 0))
    let start_idx = stridx(a:text, "\n", start_idx + 1)
  endfor
  " find the end point
  if a:0 > 0
    " okey, the optional param was provided
    if a:1 > 0
      let end_idx = start_idx
      for i in range(a:1)
        let end_idx = stridx(a:text, "\n", end_idx + 1)
        if end_idx == -1
          let end_idx = len(a:text)
          break
        endif
      endfor
    else
      let end_idx = -1
    endif
  else
    let end_idx = len(a:text)
  endif
  " convert zero base in 1 based
  let start_idx += 1
  let end_idx += 1
  return strpart(a:text, start_idx, end_idx - start_idx)
endfunction"}}}

" How many time the provided a:pattern is found within the a:text.
function! voraxlib#utils#CountMatch(text, pattern)"{{{
  let c = 0
  let last_match = -1
  while 1
    let last_match = match(a:text, a:pattern, last_match + 1)
    if last_match == -1
      " not found, just exit
      break
    endif
    let c += 1
  endwhile
  return c
endfunction"}}}

" Whenever or not the provided statement has the sql delimitator at the end.
function! voraxlib#utils#HasSqlDelimitator(statement)"{{{
  let statement = voraxlib#utils#RemoveAllSqlComments(a:statement)
  if statement =~ '\v\n\s*/\s*\n*$'
    " the statement has an ending /
  	return 1
  elseif statement =~ s:plsql_end_marker
    " the statement is a PL/SQL block but it doesn't have the ending /
    return 0
  elseif statement =~ '\v\_s*;\_s*\_$'
    " a regular statement with ; at the end
    return 1
  else
  	return 0
  endif
endfunction"}}}

" Remove the end delimitator, if any
function! voraxlib#utils#RemoveSqlDelimitator(statement)"{{{
  if voraxlib#utils#HasSqlDelimitator(a:statement)
  	return substitute(a:statement, '\v(\n+\s*/\s*\n*$)|(\_s*;\_s*\_$)', '', '')
  else
  	return a:statement
  endif
endfunction"}}}

" Adds a sql delimitator at the end of the statement.
function! voraxlib#utils#AddSqlDelimitator(statement)"{{{
  if !voraxlib#utils#HasSqlDelimitator(a:statement)
    if a:statement =~ s:plsql_end_marker
      " that's a plsql end marker add a /
      return a:statement . "\n/\n"
    else
    	" add the delimitator on the same line. This is needed because VoraX
    	" doesn't know if it's an sqlplus command or an SQL command. For
    	" example: 'SET AUTOTRACE ON;' is not the same as 'SET AUTOTRACE ON\n;'.
    	" The second is dangerous because it excutes also the previous SQL
    	" command. Likewise, take care about the trailing comment. Something
    	" like 'SELECT * FROM CAT -- my comment;' is useless.
    	return voraxlib#utils#RTrimSqlComments(a:statement) . ";"
    endif
  else
  	return a:statement
  endif
endfunction"}}}

" Whenever or not the provided statement is an oracle query.
function! voraxlib#utils#IsQuery(statement)"{{{
  if voraxlib#utils#LTrimSqlComments(a:statement) =~? '\v(^<select>)|(^<with>)'
    return 1
  else
  	return 0
  endif
endfunction"}}}

" For the identified queries identified in the a:text apply the a:limit rownum
" filter.
function! voraxlib#utils#AddRownumFilter(text, limit)"{{{
  let result = ''
  let statements = voraxlib#parser#script#Split(a:text)
  for statement in statements
    if voraxlib#utils#IsQuery(statement)
      let result .= "select * from (\n/* original query starts here */\n" . 
            \ substitute(voraxlib#utils#RemoveSqlDelimitator(statement), '\v(\_^\_s*)|(\_s*\_$)', '', 'g') . 
            \ "\n/* original query ends here */\n) where rownum <= " . string(a:limit) . ";\n"
    else
    	let result .= voraxlib#utils#AddSqlDelimitator(statement)."\n"
    endif
  endfor
  return result
endfunction"}}}

" When a db object is about to be opened, we don't want the edit window
" to be layed out randomly, or ontop of special windows like the results
" window. This procedure finds out a suitable window for opening the
" db object. If it cannot find any then a new split will be performed.
function! voraxlib#utils#FocusCandidateWindow()"{{{
  let winlist = []
  " we save the current window because the after windo we may end up in
  " another window
  let original_win = winnr()
  " iterate through all windows and get info from them
  windo let winlist += [[bufnr('%'),  winnr(), &buftype]]
  for w in winlist
    if w[2] == "nofile" || w[2] == 'quickfix' || w[2] == 'help'
      " do nothing
    else
      " great! we just found a suitable window... focus it please
      exe w[1] . 'wincmd w'
      return
    endif
  endfor
  " if here, then no suitable window was found... we'll create one
  " first of all, restore the old window
  botright vertical split new
endfunction"}}}

" Given a describe path object returns the corresponding file name for that
" object.
function! voraxlib#utils#GetFileName(object, type)"{{{
  return a:object . '.' . get(g:vorax_explorer_file_extensions, a:type, 'sql')
endfunction"}}}

" Get the line where the declaration of the package or type body begins. This
" function is internally used in order to adjust compilation errors reported
" into the ALL_ERRORS view with the actual position within the buffer.
function! voraxlib#utils#GetPlsqlBodyLine()"{{{
  if !exists('b:current_syntax') || b:current_syntax != 'plsql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  let delimitator_pattern = '^\s*\/\s*$'
  let state = winsaveview()
  " ignore events
  let _eventignore = &eventignore
  set eventignore=all
  normal gg
  let [l, c] = [0, 0]
  while 1
    let [l, c] = searchpos(delimitator_pattern, 'W')  
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == 'Statement'
      " exit if the delimitator is not within a special highlight group
      break
    endif
  endwhile
  if [l, c] != [0, 0]
    " great! we found the end delimitator of the spec. Start to look at the
    " package or type keyword.
    while 1
      let [l, c] = searchpos('\c\<package\>\|\<type\>', 'W')  
      if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == 'Statement'
        " exit if the delimitator is not within a special highlight group
        break
      endif
    endwhile
  endif
  call winrestview(state)
  " restore events
  let &eventignore = _eventignore
  return l
endfunction"}}}

" This function is used to detect the line where the declaration of a plsql
" module starts. This is used to correctly report the errors from the
" ALL_ERRORS view.
function! voraxlib#utils#GetStartLineOfPlsqlObject(type)"{{{
  if !exists('b:current_syntax') || b:current_syntax != 'plsql'
    throw 'A sql syntax must be enabled for the current buffer.'
  endif
  if a:type == 'TRIGGER'
    let pattern = '\c\<declare\>\|\<begin\>'
  elseif a:type == 'FUNCTION' || a:type == 'PROCEDURE'
    let pattern = '\c\<as\>\|\<is\>'
  elseif a:type == 'PACKAGE' || a:type == 'TYPE' || a:type == 'PACKAGE_SPEC' || a:type == 'TYPE_SPEC'
    let pattern = '\c\<package\>\|\<type\>'
  elseif a:type == 'PACKAGE_BODY' || a:type == 'TYPE_BODY'
    return voraxlib#utils#GetPlsqlBodyLine()
  else
  	return 0
  endif
  let state = winsaveview()
  " ignore events
  let _eventignore = &eventignore
  set eventignore=all
  normal gg
  let [l, c] = [0, 0]
  while 1
    let [l, c] = searchpos(pattern, 'W')  
    if [l, c] == [0, 0] || synIDattr(synIDtrans(synID(l, c, 1)), "name") == 'Statement'
      " exit if the delimitator is not within a special highlight group
      break
    endif
  endwhile
  call winrestview(state)
  " restore events
  let &eventignore = _eventignore
  return l
endfunction"}}}

" Get all errors from the ALL_VIEW to be filled in the quick fix window.
function! voraxlib#utils#GetQuickFixCompilationErrors(owner, object, type)"{{{
  if a:type == 'PACKAGE' || a:type == 'TYPE'
    let offset_spec = voraxlib#utils#GetStartLineOfPlsqlObject(a:type . '_SPEC')
    let offset_body = voraxlib#utils#GetStartLineOfPlsqlObject(a:type . '_BODY')
    if offset_spec > 0 && offset_body > 0
      let offset = "decode(type, '" . a:type . "', " . (offset_spec - 1) . ", " .
                  \ "decode(type, '" . a:type . " BODY', " . (offset_body - 1) . ", 0)" . ")"
    else
      let offset = 0
    endif
    let filter_clause = "('" . a:type . "', '" . a:type . " BODY')"
  else
    let offset = voraxlib#utils#GetStartLineOfPlsqlObject(a:type) - 1
    if offset > 0
      let offset -= 1
    endif
    let filter_clause = "('" . a:type . "')"
  endif
  let query = "select  line + " . offset . " line, " .
                    \ "position, " . 
                    \ "replace(replace(text, chr(10), ' '), chr(92), chr(92) || chr(92)) text " .
                  \ "from all_errors " . 
                  \ "where owner = '" . a:owner . "' " .
                  \ "and name = '" . a:object . "' " .
                  \ "and type in " . filter_clause . " order by 1;"
  let data = vorax#GetSqlplusHandler().Query(query)
  if empty(data.errors)
    let qerr = []
    for record in data.resultset
      let qerr += [{'bufnr' : bufnr('%'), 'lnum' : str2nr(record['LINE']), 
            \ 'col' : str2nr(record['POSITION']), 'text' : record['TEXT']}]
    endfor
    return qerr
  endif
  return []
endfunction"}}}

let &cpo = s:cpo_save
unlet s:cpo_save

