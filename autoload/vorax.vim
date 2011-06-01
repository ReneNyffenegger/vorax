" Description: VoraX autoload buddy.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_vorax") 
 finish
endif

let g:_loaded_vorax = 1
let s:cpo_save = &cpo
set cpo&vim

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" Create the sqlplus instance
let s:sqlplus = voraxlib#sqlplus#New()

" Create the output window instance
let s:output = voraxlib#panel#output#New()

" Create the profiles manager
let s:profiles = voraxlib#panel#profiles#New()

" The default throbber
let s:default_throbber = voraxlib#widget#throbber#New(g:vorax_throbber_chars)

" Connects to the provided database using the cstr
" connection string. The cstr has the common sqlplus
" format user/password@db [as sys(dba|asm|oper). It also
" accepts incomplete formats like user@db or just user, the
" user being prompted afterwards for the missing parts.
function! vorax#Connect(cstr, bang)"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Connect(' . string(a:cstr) . ')') | endif
  " reset the last executed statement
  let s:sqlplus.last_stmt = ''
  if s:sqlplus.GetPid() && a:bang == '!'
    " destroy the sqlplus process if any attached
    if s:log.isDebugEnabled() | call s:log.debug('Connect with bang. Destroy the old attached sqlplus process.') | endif
    call vorax#ResetSqlplusHandler()
  endif
  if s:sqlplus.GetPid()
    " set the session owner monitor policy
    call s:sqlplus.SetSessionOwnerMonitor(g:vorax_session_owner_monitor)
    let cstr = voraxlib#connection#Ask(a:cstr)
    if cstr != ''
      let output = s:sqlplus.Exec("connect " . cstr, 
            \ {'executing_msg' : 'Connecting...' , 
            \  'throbber' : s:default_throbber,
            \  'done_msg' : 'Done.',
            \  'sqlplus_options' : [{'option' : 'sqlprompt', 'value' : "''"}]})
      if s:sqlplus.GetPid()
        " only if sqlplus process is still alive
        call s:output.AppendText(s:sqlplus.GetBanner() . "\n\n")
        if !voraxlib#utils#HasErrors(output)
          call s:output.AppendText(s:sqlplus.Exec("prompt &_O_VERSION", 
                \ {'sqlplus_options' : [{'option' : 'define', 'value' : '"&"'}]}))
        endif
        call s:output.AppendText("\n" . output)
      endif
    else
      echo 'Aborted!'
    endif
  endif
  if s:log.isTraceEnabled() | call s:log.trace("END vorax#Connect") | endif
endfunction"}}}

" Execute the provided command and spit the result into the output window.
function! vorax#Exec(command)"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  if s:ShouldGoOnWithPauseOn()
    if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Exec(' . string(a:command) . ')') | endif
    " save the last command. this is require in order to be able to replay it.
    let sqlplus.last_stmt = voraxlib#utils#AddSqlDelimitator(a:command)
    if s:log.isDebugEnabled() | call s:log.debug('with delimitator added: '.string(sqlplus.last_stmt)) | endif
    if exists('g:vorax_limit_rows') && g:vorax_limit_rows > 0
      let sqlplus.last_stmt = voraxlib#utils#AddRownumFilter(sqlplus.last_stmt, g:vorax_limit_rows)
      if s:log.isDebugEnabled() | call s:log.debug('limit rows enabled. statements coverted to: '.string(sqlplus.last_stmt)) | endif
    endif
    " exec the command in bg. All trailing CR/spaces are removed before exec.
    " This is important especially in connection with set echo on. With CRs
    " the sqlprompt will be echoed
    call sqlplus.NonblockExec(sqlplus.Pack(substitute(sqlplus.last_stmt, '\_s*\_$', '', 'g'), {'include_eor' : 1}), 0)
    call s:output.StartMonitor()
  else
    if s:log.isDebugEnabled() | call s:log.debug('User decided to cancel the exec because of the pause on.') | endif
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#Exec') | endif
endfunction"}}}

" Execute the statement under cursor form the current buffer.
function! vorax#ExecCurrent()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#ExecCurrent()') | endif
  if voraxlib#utils#IsSqlOracleBuffer()
    try
      let [start_l, start_c] = voraxlib#utils#GetStartOfCurrentSql(0)
      let [end_l, end_c] = voraxlib#utils#GetEndOfCurrentSql(0)
      if s:log.isDebugEnabled() | call s:log.debug('[start_l, start_c, end_l, end_c] = [' . start_l . ', ' . start_c . ', ' . end_l . ', ' . end_c . ']') | endif
      if voraxlib#utils#IsHighlightEnabled()
        " highlight the statement under cursor
        call voraxlib#utils#HighlightRange(g:vorax_statement_highlight_group, 
              \ start_l, start_c, end_l, end_c)
      endif
      let statement = voraxlib#utils#GetTextFromRange(start_l, start_c, end_l, end_c)
      let statement = voraxlib#utils#TrimSqlComments(statement)
      call vorax#Exec(statement)
    catch /^A sql syntax must be enabled for the current buffer.$/
      call voraxlib#utils#Warn("Cannot detect the current statement if syntax is not enabled!")
      if s:log.isErrorEnabled() | call s:log.error('Syntax is not enabled! Cannot detect the current statement.') | endif
    endtry
  else
    call voraxlib#utils#Warn("Cannot execute the current statement from a non sql oracle buffer.")
    if s:log.isErrorEnabled() | call s:log.error('The originating buffer is not an sql oracle one.') | endif
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#ExecCurrent') | endif
endfunction"}}}

" Execute the currently selected block in the current buffer.
function! vorax#ExecSelection()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#ExecSelection()') | endif
  if voraxlib#utils#IsHighlightEnabled()
    " highlight the statement under cursor
    call voraxlib#utils#HighlightRange(g:vorax_statement_highlight_group, 
          \ getpos("'<")[1], virtcol("'<"), getpos("'>")[1], virtcol("'>"))
  endif
  call vorax#Exec(voraxlib#utils#SelectedBlock())
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#ExecSelection') | endif
endfunction"}}}

" Provides completion for profile names. It is used in the VoraxConnect
" command.
function! vorax#ProfilesForCompletion(arglead, cmdline, cursorpos)"{{{
  let profiles = s:profiles.GetAll()
  let profile_names =  voraxlib#utils#SortUnique(
        \ map(filter(copy(profiles), 
              \ 'has_key(v:val, "id") && v:val.id =~ ''^'' . a:arglead'), 
              \ 'v:val.id'))
  return profile_names
endfunction"}}}

" Toggle the spooling of output to the configured spool file.
function! vorax#ToggleSpooling()"{{{
  let output_window = vorax#GetOutputWindowHandler()
  if output_window.spooling
    " disable spooling
    call output_window.StopSpooling()
    " redraw here because the statusline of the output window must also be
    " refreshed after disabling.
    redraw!
    echo 'Spooling stopped.'
  else
    let spool_file = output_window.spool_file
    if exists('g:vorax_output_window_default_spool_file') &&
          \ g:vorax_output_window_default_spool_file != ''
      let spool_file = eval(g:vorax_output_window_default_spool_file)
    endif
    " enable spooling
    call output_window.StartSpooling(spool_file)
    " redraw here because the statusline of the output window must also be
    " refreshed after enabling.
    redraw!
    echo 'Spooling started in ' . output_window.spool_file
  endif
endfunction"}}}

" Toggle pretty print for the sqlplus output.
function! vorax#ToggleCompressedOutput()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let output_win = vorax#GetOutputWindowHandler()
  if sqlplus.html && !output_win.buffer.vertical
    call sqlplus.DisableHtml()
    let output_win.buffer.vertical = 0
    " redraw here because the statusline of the output window must also be
    " refreshed after disabling.
    redraw!
    echo 'Compressed output disabled!'
  else
    call sqlplus.EnableHtml()
    let output_win.buffer.vertical = 0
    " redraw here because the statusline of the output window must also be
    " refreshed after enabling.
    redraw!
    echo 'Compressed output enabled!'
  endif
endfunction"}}}

" Toggle vertical layout output.
function! vorax#ToggleVerticalOutput()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let output_win = vorax#GetOutputWindowHandler()
  if sqlplus.html && output_win.buffer.vertical
    call sqlplus.DisableHtml()
    let output_win.buffer.vertical = 1
    " redraw here because the statusline of the output window must also be
    " refreshed after disabling.
    redraw!
    echo 'Vertical layout output disabled!'
  else
    call sqlplus.EnableHtml()
    let output_win.buffer.vertical = 1
    " redraw here because the statusline of the output window must also be
    " refreshed after enabling.
    redraw!
    echo 'Vertical layout output enabled!'
  endif
endfunction"}}}

" Toggle the ROWNUM limit filter
function! vorax#ToggleLimitRows()"{{{
  if exists('g:vorax_limit_rows') && g:vorax_limit_rows > 0
  	let s:last_vorax_limit_rows = g:vorax_limit_rows
  	let g:vorax_limit_rows = 0
    redraw!
    echo 'ROWNUM limit filter has been removed!'
  else
    let s:filter_checker = { 'prompt' : 'Maximum number of records: ', 
                           \ 'check'  : [
                                          \ {'regexp' : '[0-9]\+',
                                          \  'errmsg' : 'Please specify a valid number.'},
                                          \ ],
                           \ 'default': (exists('s:last_vorax_limit_rows') ? s:last_vorax_limit_rows : '')
                           \ }
    let limit = voraxlib#utils#Ask(s:filter_checker)
    if limit != ''
      let g:vorax_limit_rows = str2nr(limit)
      redraw!
      echo 'ROWNUM limit filter has been activated!'
    endif
  endif
endfunction"}}}

" Get the profiles manager object.
function! vorax#GetProfilesHandler()"{{{
  return s:profiles
endfunction"}}}

" Get the sqlplus wrapper object.
function! vorax#GetSqlplusHandler()"{{{
  if !s:sqlplus.GetPid()
    let s:sqlplus = voraxlib#sqlplus#New()
  endif
  return s:sqlplus
endfunction"}}}

" Destroys the current sqlplus handler and creates a new one.
function! vorax#ResetSqlplusHandler()"{{{
  call s:sqlplus.Destroy()
  let s:sqlplus = voraxlib#sqlplus#New()
endfunction"}}}

" Get the default throbber
function! vorax#GetDefaultThrobber()"{{{
  return s:default_throbber
endfunction"}}}

" Get the output window object.
function! vorax#GetOutputWindowHandler()"{{{
  return s:output
endfunction"}}}

" === PRIVATE FUNCTIONS ==="{{{

" Display a warning if the sqlplus pause option is on but only if
" g:vorax_sqlplus_pause_warning is 1.
function! s:ShouldGoOnWithPauseOn()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  if exists('g:vorax_sqlplus_pause_warning') && 
        \ g:vorax_sqlplus_pause_warning && 
        \ sqlplus.IsPauseOn()
    " if sqlplus is configured with PAUSE ON
    call voraxlib#utils#Warn("Warning: sqlplus PAUSE option is on.\n" . 
          \ "It's better to user VoraX paginating feature!\n".
          \ "If you decide to continue then, don't forget that in order\n" .
          \ "to fetch the next page you have to press <cr> twice.\n")
    let response = voraxlib#utils#PickOption(
        \ 'Are you sure you want to continue?',
        \ ['(Y)es', '(N)o'])
    if response == 'N'
    	redraw
    	echo 'Cancelled.'
    	return 0
    end
  endif
  return 1
endfunction"}}}

"}}}

let &cpo=s:cpo_save
unlet s:cpo_save

