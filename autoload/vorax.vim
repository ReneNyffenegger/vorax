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

" In case it's a script reload (see testing) then ensure the following vars
" are cleaned up
if exists('s:profiles') | unlet s:profiles | endif
if exists('s:sqlplus') | unlet s:sqlplus | endif
if exists('g:vorax_explorer') | unlet g:vorax_explorer | endif
if exists('s:output') | unlet s:output | endif
if exists('s:default_throbber') | unlet s:default_throbber | endif

" Connects to the provided database using the cstr
" connection string. The cstr has the common sqlplus
" format user/password@db [as sys(dba|asm|oper). It also
" accepts incomplete formats like user@db or just user, the
" user being prompted afterwards for the missing parts.
function! vorax#Connect(cstr, bang)"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Connect(' . string(a:cstr) . ')') | endif
  let sqlplus = vorax#GetSqlplusHandler()
  let outputwin = vorax#GetOutputWindowHandler()
  let explorer = vorax#GetExplorerHandler()
  " reset the last executed statement
  let sqlplus.last_stmt = {}
  if sqlplus.GetPid() && a:bang == '!'
    " destroy the sqlplus process if any attached
    if s:log.isDebugEnabled() | call s:log.debug('Connect with bang. Destroy the old attached sqlplus process.') | endif
    call vorax#ResetSqlplusHandler()
    " The old handler becomes invalid, reassign
    let sqlplus = vorax#GetSqlplusHandler()
  endif
  if sqlplus.GetPid()
    " set the session owner monitor policy
    call sqlplus.SetSessionOwnerMonitor(g:vorax_session_owner_monitor)
    let cstr = voraxlib#connection#Ask(a:cstr)
    if cstr != ''
      let output = sqlplus.Exec("connect " . cstr, 
            \ {'executing_msg' : 'Connecting...' , 
            \  'throbber' : vorax#GetDefaultThrobber(),
            \  'done_msg' : 'Done.',
            \  'sqlplus_options' : [{'option' : 'sqlprompt', 'value' : "''"}]})
      if sqlplus.GetPid()
        " only if sqlplus process is still alive
        call outputwin.AppendText(sqlplus.GetBanner() . "\n\n")
        if !voraxlib#utils#HasErrors(output)
          call outputwin.AppendText(sqlplus.Exec("prompt &_O_VERSION", 
                \ {'sqlplus_options' : [{'option' : 'define', 'value' : '"&"'}, 
                                      \ {'option' : 'sqlprompt', 'value' : "''"}]}))
        endif
        call outputwin.AppendText("\n" . output)
      endif
      " refresh the vorax db explorer window tree
      let explorer.expanded_nodes = []
      if explorer.window.IsOpen()
        call explorer.Refresh()
      else
        " postpone refresh until toggle
        let explorer.root = ''
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
  let outputwin = vorax#GetOutputWindowHandler()
  if s:ShouldGoOnWithPauseOn()
    if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Exec(' . string(a:command) . ')') | endif
    " save the last command. this is require in order to be able to replay it.
    let sqlplus.last_stmt = {'cmd' : voraxlib#utils#AddSqlDelimitator(a:command), 'from_buf' : bufnr('%')}
    if s:log.isDebugEnabled() | call s:log.debug('with delimitator added: '.string(sqlplus.last_stmt)) | endif
    if exists('g:vorax_limit_rows') && g:vorax_limit_rows > 0
      let sqlplus.last_stmt = voraxlib#utils#AddRownumFilter(sqlplus.last_stmt['cmd'], g:vorax_limit_rows)
      if s:log.isDebugEnabled() | call s:log.debug('limit rows enabled. statements coverted to: '.string(sqlplus.last_stmt)) | endif
    endif
    " exec the command in bg. All trailing CR/spaces are removed before exec.
    " This is important especially in connection with set echo on. With CRs
    " the sqlprompt will be echoed
    call sqlplus.NonblockExec(sqlplus.Pack(substitute(sqlplus.last_stmt['cmd'], '\_s*\_$', '', 'g'), {'include_eor' : 1}), 0)
    call outputwin.StartMonitor()
  else
    if s:log.isDebugEnabled() | call s:log.debug('User decided to cancel the exec because of the pause on.') | endif
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#Exec') | endif
endfunction"}}}

" Send the whole current buffer content to sqlplus for execution.
function! vorax#CompileBuffer()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#CompileBuffer()') | endif
  if &ft == 'plsql'
    " get the content of the buffer
    let content = join(getline(0, line('$')), "\n")
    if substitute(content, '\_s', '', 'g') != ''
      " only if it's not empty
      let sqlplus = vorax#GetSqlplusHandler()
      let content = voraxlib#utils#AddSqlDelimitator(content)
      " execute the buffer content which, for a plsql buffer, it means a compilation
      let exec_file = sqlplus.Pack(substitute(content, '\_s*\_$', '', 'g'), {'include_eor' : 1}) 
      let output = sqlplus.Exec(exec_file, {'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
            \ [
            \ {'option' : 'echo', 'value' : 'off'}, 
            \ {'option' : 'feedback', 'value' : 'on'},
            \ {'option' : 'markup', 'value' : 'html off'},
            \ ])})
      " look for errors in ALL_ERRORS view
      call voraxlib#utils#DisplayCompilationErrors(b:vorax_module['owner'], 
                                                 \ b:vorax_module['object'], 
                                                 \ b:vorax_module['type'])
      call vorax#GetOutputWindowHandler().AppendText(output)
      " refresh db explorer
      if g:vorax_explorer.window.IsOpen()
        call g:vorax_explorer.Refresh()
      else
        let g:vorax_explorer.must_refresh = 1
      endif
      " go back to the previous buffer
      wincmd p
    else
      if s:log.isErrorEnabled() | call s:log.error('Empty buffer!') | endif
    	call voraxlib#utils#Warn('Nothing to compile. Empty buffer!')
    endif
  else
    if s:log.isErrorEnabled() | call s:log.error('Not a PL/SQL buffer!') | endif
    call voraxlib#utils#Warn('Only PL/SQL buffers can be compiled.')
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#CompileBuffer()') | endif
endfunction"}}}

" Execute the statement under cursor form the current buffer.
function! vorax#ExecCurrent()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#ExecCurrent()') | endif
  if voraxlib#utils#IsSqlOracleBuffer()
    try
      call voraxlib#utils#SelectCurrentStatement()
      call vorax#ExecSelection()
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
  call vorax#Exec(voraxlib#utils#SelectedBlock())
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#ExecSelection') | endif
endfunction"}}}

" Returns an array of lines with the source code for the provided
" schema.object_name having the a:type specified. The optional param is a hash
" with the following structure {'executing_msg' : '', 'throbber': ,
" 'done_msg': ''}. (for details see the sqlplus.Query method).
function! vorax#GetDDL(schema, object_name, type, ...)"{{{
  let query = "set long 1000000000 longc 60000\n" .
            \ "set wrap on\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'BODY', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', TRUE );\n" .
            \ "select dbms_metadata.get_ddl('" . a:type . "', '" . a:object_name . "', '" . a:schema . "') src from dual;"
  let sqlplus = vorax#GetSqlplusHandler()
  let params = {}
  if exists('a:1')
  	let params = a:1
  endif
  let output = sqlplus.Query(query, params)
  if empty(output.errors)
    if !empty(output.resultset)
      return split(output.resultset[0]['SRC'], '\r\?\n')
    endif
  else
    call voraxlib#utils#Warn("WTF? What's with this error?\n" . join(output.errors, "\n"))
    return []
  endif
endfunction"}}}

" Load the provided schema.object_name of type a:type for editing.
function! vorax#LoadDbObject(schema, object_name, type)"{{{
  let file_name = voraxlib#utils#GetFileName(a:object_name, a:type)
  let bufnr = bufnr(file_name)
  if bufnr == -1 || join(getbufline(bufnr, 0, '$'), '') == ''
    " create a new buffer
  	let params = {'executing_msg' : 'Fetching source for ' . a:object_name . '...',
        \  'throbber' : vorax#GetDefaultThrobber(),
        \  'done_msg' : 'Done.'}
    let src = vorax#GetDDL(a:schema, a:object_name, a:type, params)
    if !empty(src)
      " remove leading blanks from the first line
      let src[0] = substitute(src[0], '^\s*', '', 'g')
      call s:OpenDbBuffer(file_name, src)
      let b:vorax_module = {'owner' : a:schema, 'type' : a:type, 'object' : a:object_name}
    else
      redraw
      call voraxlib#utils#Warn('Empty source for the requested database object.')
    endif
  else
    if bufnr != -1
      " just focus that buffer
      silent call voraxlib#utils#FocusCandidateWindow()
      exe 'buffer ' . bufnr
    endif
  endif
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

" Toggle paginating
function! vorax#TogglePaginating()"{{{
  if exists('g:vorax_output_window_pause') && g:vorax_output_window_pause
  	" disable paginating
    let g:vorax_output_window_pause = 0
    redraw!
    echo 'Output paginating disabled!'
  else
  	" enable paginating
    let g:vorax_output_window_pause = 1
    redraw!
    echo 'Output paginating enabled!'
  endif
endfunction"}}}

" Get the profiles manager object.
function! vorax#GetProfilesHandler()"{{{
  if !exists('s:profiles')
    " Create the profiles manager
    let s:profiles = voraxlib#panel#profiles#New()
  endif
  return s:profiles
endfunction"}}}

" Get the vorax explorer object.
function! vorax#GetExplorerHandler()"{{{
  if !exists('g:vorax_explorer')
    " Create the db explorer
    call voraxlib#panel#explorer#New()
  endif
  return g:vorax_explorer
endfunction"}}}

" Get the sqlplus wrapper object.
function! vorax#GetSqlplusHandler()"{{{
  if !exists('s:sqlplus') || !s:sqlplus.GetPid()
    let s:sqlplus = voraxlib#sqlplus#New()
  endif
  return s:sqlplus
endfunction"}}}

" Destroys the current sqlplus handler and creates a new one.
function! vorax#ResetSqlplusHandler()"{{{
  if exists('s:sqlplus')
    call s:sqlplus.Destroy()
  endif
  let s:sqlplus = voraxlib#sqlplus#New()
endfunction"}}}

" Get the default throbber
function! vorax#GetDefaultThrobber()"{{{
  if !exists('s:default_throbber')
    " The default throbber
    let s:default_throbber = voraxlib#widget#throbber#New(g:vorax_throbber_chars)
  endif
  return s:default_throbber
endfunction"}}}

" Get the output window object.
function! vorax#GetOutputWindowHandler()"{{{
  if !exists('s:output')
    " Create the output window instance
    let s:output = voraxlib#panel#output#New()
  endif
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

" Open a buffer under the provided file_name and with the a:content array.
function! s:OpenDbBuffer(file_name, content)"{{{
  silent! call voraxlib#utils#FocusCandidateWindow()
  silent! exe 'edit ' . a:file_name
  " clear content if the file exists
  normal gg"_dG
  call append(0, a:content)
  setlocal nomodified
  normal gg
endfunction"}}}

"}}}

let &cpo=s:cpo_save
unlet s:cpo_save

