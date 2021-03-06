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
let s:script_dir = expand('<sfile>:p:h')

" In case it's a script reload (see testing) then ensure the following vars
" are cleaned up
if exists('s:profiles') | unlet s:profiles | endif
if exists('s:sqlplus') | unlet s:sqlplus | endif
if exists('g:vorax_explorer') | unlet g:vorax_explorer | endif
if exists('s:output') | unlet s:output | endif
if exists('s:docwin') | unlet s:docwin | endif
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
      let output = sqlplus.GetBanner() . "\n\n"
      let conn_output = sqlplus.Exec("connect " . cstr, 
            \ {'executing_msg' : 'Connecting...' , 
            \  'throbber' : vorax#GetDefaultThrobber(),
            \  'done_msg' : 'Done.',
            \  'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
                                      \ [
                                      \ {'option' : 'echo', 'value' : 'off'}, 
                                      \ {'option' : 'feedback', 'value' : 'on'},
                                      \ {'option' : 'sqlprompt', 'value' : "''"},
                                      \ {'option' : 'markup', 'value' : 'html off'},
                                      \ ]) 
            \ })
      if sqlplus.GetPid()
        " only if sqlplus process is still alive
        if !voraxlib#utils#HasErrors(conn_output)
          let output .= sqlplus.Exec("prompt &_O_VERSION", 
            \  {'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
                                      \ [
                                      \ {'option' : 'echo', 'value' : 'off'}, 
                                      \ {'option' : 'feedback', 'value' : 'on'},
                                      \ {'option' : 'markup', 'value' : 'html off'},
                                      \ {'option' : 'define', 'value' : '"&"'}, 
                                      \ {'option' : 'sqlprompt', 'value' : "''"}])}) . "\n" . conn_output
          if sqlplus.HasDbaRights()
            let sqlplus['query_dba'] = 1
          else
            let sqlplus['query_dba'] = 0
          endif
        endif
        call outputwin.AppendText(substitute(output, '\_s*$', '', '') . "\n", g:vorax_output_window_clear_before_exec)
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
function! vorax#Exec(command, ...)"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let outputwin = vorax#GetOutputWindowHandler()
  if exists('a:1')
  	let pack = a:1
  else
  	let pack = 1
  endif
  if s:ShouldGoOnWithPauseOn()
    if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Exec(' . string(a:command) . ')') | endif
    " save the last command. this is require in order to be able to replay it.
    let sqlplus.last_stmt = {'cmd' : voraxlib#utils#AddSqlDelimitator(a:command), 'from_buf' : bufnr('%')}
    if s:log.isDebugEnabled() | call s:log.debug('with delimitator added: '.string(sqlplus.last_stmt)) | endif
    " limiting rows logic
    if exists('g:vorax_limit_rows') && g:vorax_limit_rows > 0
      let statements = voraxlib#parser#script#Split(sqlplus.last_stmt['cmd'])
      let sqlplus.last_stmt['cmd'] = voraxlib#utils#AddRownumFilter(statements, g:vorax_limit_rows)
      if s:log.isDebugEnabled() | call s:log.debug('limit rows enabled. statements coverted to: '.string(sqlplus.last_stmt)) | endif
    endif
    " force column headings
    if exists('g:vorax_output_window_force_column_heading') && g:vorax_output_window_force_column_heading
      let queries = []
      if !exists('statements')
        let statements = voraxlib#parser#script#Split(sqlplus.last_stmt['cmd'])
      endif
      for statement in statements
        if voraxlib#utils#IsQuery(statement)
          call add(queries, substitute(voraxlib#utils#RemoveSqlDelimitator(statement), '\v(\_^\_s*)|(\_s*\_$)', '', 'g'))
        endif
      endfor
      let cmds = sqlplus.EnforceColumnsHeading(queries)
      call sqlplus.Exec(join(cmds['format_commands'], "\n"))
    endif
    " exec the command in bg. All trailing CR/spaces are removed before exec.
    " This is important especially in connection with set echo on. With CRs
    " the sqlprompt will be echoed
    if pack 
    	let run_this = sqlplus.Pack(substitute(sqlplus.last_stmt['cmd'], '\_s*\%$', '', 'g')
          \ , {'include_eor' : 1}) 
    else
    	let run_this = substitute(sqlplus.last_stmt['cmd'], '\_s*\%$', '', 'g')
    endif
    call sqlplus.NonblockExec( run_this . 
          \ (exists('cmds') ? "\n" . join(cmds['reset_commands'], "\n") : '')
          \ , 0)
    call outputwin.StartMonitor()
  else
    if s:log.isDebugEnabled() | call s:log.debug('User decided to cancel the exec because of the pause on.') | endif
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END vorax#Exec') | endif
endfunction"}}}

" Describe the provided identifier
function! vorax#Describe(identifier, verbose)"{{{
  let identifier = a:identifier
  if identifier == ''
    " if the identifier is empty assume the one under cursor
    let identifier = voraxlib#utils#GetIdentifierUnderCursor()
  endif
  let object_data = voraxlib#utils#ResolveDbObject(identifier)
  if exists('object_data.type') && 
        \ object_data.type =~ '^\(TABLE\)\|\(VIEW\)\|\(PACKAGE\)\|\(TYPE\)\|\(FUNCTION\)\|\(PROCEDURE\)$'
    let sqlplus = vorax#GetSqlplusHandler()
    let outputwin = vorax#GetOutputWindowHandler()
    let crr_win = winnr()
    if a:verbose
      if object_data.type =~ '^\(TABLE\)\|\(VIEW\)$'
        " verbose desc is availablre for tables and views only
        let desc_script = fnamemodify(s:script_dir . '/../vorax/scripts/desc_table.sql', ':p:8')
        let desc_script = sqlplus.ConvertPath(substitute(desc_script, '\\\\\|\\', '/', 'g'))
        let output = sqlplus.Exec("@" . desc_script . ' "' . object_data.schema . '" "' . object_data.object . '"' , 
              \ {'executing_msg' : 'Fetching describe info for ' . object_data.schema . "." . object_data.object . '...',
              \  'throbber' : vorax#GetDefaultThrobber(),
              \  'done_msg' : 'Done.',
              \  'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
                  \ [
                  \ {'option' : 'echo', 'value' : 'off'}, 
                  \ {'option' : 'feedback', 'value' : 'off'},
                  \ {'option' : 'verify', 'value' : 'off'},
                  \ {'option' : 'define', 'value' : 'on'},
                  \ {'option' : 'sqlprompt', 'value' : "''"},
                  \ {'option' : 'linesize', 'value' : '180'},
                  \ {'option' : 'markup', 'value' : 'html off'},
                \ ])})
      endif
    else
      " simple desc
      let object = object_data.schema . '.' . object_data.object . (object_data.dblink != '' ? '@' .object_data.dblink : '')
      let output = sqlplus.Exec("desc " . object,
            \ {'executing_msg' : 'Fetching describe info for ' . object . '...',
            \  'throbber' : vorax#GetDefaultThrobber(),
            \  'done_msg' : 'Done.',
            \ 'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
              \ [
              \ {'option' : 'echo', 'value' : 'off'}, 
              \ {'option' : 'feedback', 'value' : 'on'},
              \ {'option' : 'sqlprompt', 'value' : "''"},
              \ {'option' : 'linesize', 'value' : '120'},
              \ {'option' : 'markup', 'value' : 'html off'},
              \ ])})
    endif
    if exists('output')
      call outputwin.AppendText(output, g:vorax_output_window_clear_before_exec)
    endif
    if !g:vorax_output_window_keep_focus_after_exec
      exec crr_win . 'wincmd w'
    endif
  endif
endfunction"}}}

" Explain plan for the provided a:sql. If a:only is 1 then just an explain
" only is issued without executing the statement.
function! vorax#Explain(sql, only)"{{{
  let statement = a:sql
  if empty(statement)
    " assume the current statement
    let statement = voraxlib#utils#GetCurrentStatement()
  endif
  let statement = voraxlib#utils#AddSqlDelimitator(statement)
  let sqlplus = vorax#GetSqlplusHandler()
  let outputwin = vorax#GetOutputWindowHandler()
  if sqlplus.html && outputwin.buffer.vertical 
    call voraxlib#utils#Warn("Vertical output display is incompatible with the explain plan format.")
    let response = voraxlib#utils#PickOption(
          \ 'Do you want to disable the current vertical output format?',
          \ ['(Y)es', '(N)o'])
    if response == 'Y'
      call vorax#ToggleVerticalOutput()
    else
    	return
    endif
  endif
  call sqlplus.SaveState()
  let crr_win = winnr()
  let sql_file = substitute(sqlplus.Pack(statement, {'target_file' : 'stmt_to_be_explained.sql'}), '^@', '', '')
  if a:only
    let explain_script = fnamemodify(s:script_dir . '/../vorax/scripts/explain_only.sql', ':p:8')
  else
    let explain_script = fnamemodify(s:script_dir . '/../vorax/scripts/explain.sql', ':p:8')
  endif
  let explain_script = sqlplus.ConvertPath(substitute(explain_script, '\\\\\|\\', '/', 'g'))
  let explain_command = sqlplus.Pack('@' . explain_script . ' ' . 
        \ shellescape(sqlplus.ConvertPath(sql_file)) . ' ' . 
        \ shellescape(g:vorax_explain_options),
        \ {'include_eor' : 1})
  let explain_command = "set echo off " .
                      \ "feedback off " .
                      \ "verify off " .
                      \ "define on " .
                      \ "sqlprompt '' " .
                      \ "linesize 180 " .
                      \ "\n" . explain_command .
                      \ "\n" . join(readfile(sqlplus.GetStagingSqlplusSettingsFile()), "\n")
  call vorax#Exec(explain_command, 0)
endfunction"}}}

" Send the whole current buffer content to sqlplus for execution.
function! vorax#CompileBuffer()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#CompileBuffer()') | endif
  if &ft == 'plsql'
    redraw
    echo 'Compiling...'
    " get the content of the buffer
    let content = join(getline(0, line('$')), "\n")
    if substitute(content, '\_s', '', 'g') != ''
      let crr_win = winnr()
      " only if it's not empty
      let sqlplus = vorax#GetSqlplusHandler()
      "let content = voraxlib#utils#AddSqlDelimitator(content)
      " execute the buffer content which, for a plsql buffer, it means a compilation
      let exec_file = sqlplus.Pack(substitute(content, '\_s*\%$', '', 'g'), {'include_eor' : 1}) 
      let output = sqlplus.Exec(exec_file, {
            \ 'sqlplus_options' : extend(sqlplus.GetSafeOptions(), 
              \ [
              \ {'option' : 'echo', 'value' : 'off'}, 
              \ {'option' : 'feedback', 'value' : 'on'},
              \ {'option' : 'markup', 'value' : 'html off'},
              \ ])})
      " look for errors in ALL_ERRORS view
      let buffer_metadata = voraxlib#utils#DescribeCurrentBuffer()
      if s:log.isDebugEnabled() | call s:log.debug('buffer metadata: '. string(buffer_metadata)) | endif
      let qerr = voraxlib#utils#GetQuickFixCompilationErrors(buffer_metadata['object_owner'], 
                                                 \ buffer_metadata['object_name'], 
                                                 \ buffer_metadata['object_type'])
      if len(qerr) > 0
        " set cursor on the first error
        call setpos('.', [qerr[0]["bufnr"], qerr[0]["lnum"], qerr[0]["col"], 0])
        " if we have errors to show
        call setqflist(qerr, 'r')
        botright cwindow
      else
        " just close the cwindow
        cclose
      endif
      call vorax#GetOutputWindowHandler().AppendText(output, g:vorax_output_window_clear_before_exec)
      " go back to the originating buffer
      exe crr_win . 'wincmd w'
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
  let statement = "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'BODY', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE );\n" .
            \ "exec dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', TRUE );\n" .
            \ "select dbms_metadata.get_ddl('" . a:type . "', '" . a:object_name . "', '" . a:schema . "') from dual;"
  let sqlplus = vorax#GetSqlplusHandler()
  let params = {}
  if exists('a:1')
  	let params = a:1
  endif
  let params['sqlplus_options'] = extend(sqlplus.GetSafeOptions(), 
                            \ [{'option' : 'serveroutput', 'value' : 'on size 1000000'},
                            \  {'option' : 'pagesize', 'value' : '0'},
                            \  {'option' : 'long', 'value' : '1000000000'},
                            \  {'option' : 'longc', 'value' : '60000'},
                            \  {'option' : 'feedback', 'value' : 'off'},
                            \  {'option' : 'echo', 'value' : 'off'}, 
                            \  {'option' : 'markup', 'value' : 'html off'},
                            \ ])
  let output = sqlplus.Exec(sqlplus.Pack(statement, {'include_eor' : 1}), params)
  " get rid of \r stuff
  let output = substitute(output, '\%(\_s\|[\r]\)*$', '', 'g')
  if !voraxlib#utils#HasErrors(output)
    return split(output, '\r\?\n')
  else
    call voraxlib#utils#Warn("Cannot load object definition.\n"))
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

" Toggle the display of the output window
function! vorax#ToggleOutputWindow()"{{{
  let output_win = vorax#GetOutputWindowHandler()
  call output_win.Toggle()
endfunction"}}}

" Get the profiles manager object.
function! vorax#GetProfilesHandler()"{{{
  if !exists('s:profiles')
    " Create the profiles manager
    let s:profiles = voraxlib#panel#profiles#New()
  endif
  return s:profiles
endfunction"}}}

" Get the doc window object.
function! vorax#GetDocwinHandler()"{{{
  if !exists('s:docwin')
    " Create the docwin
    let s:docwin = voraxlib#panel#docwin#New()
  endif
  return s:docwin
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

" Create key mappings for sql and plsql buffers (common mappings)
function! vorax#CreateCommonKeyMappings()"{{{
  " describe mappings
  let mapdesc = maparg(g:vorax_describe_key, 'n', 0, 1)
  if g:vorax_describe_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "nmap <silent> <unique> <buffer> " . g:vorax_describe_key . " <Plug>VoraxDescribe"
  endif
  let mapdesc = maparg(g:vorax_describe_verbose_key, 'n', 0, 1)
  if g:vorax_describe_verbose_key!= '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "nmap <silent> <unique> <buffer>" . g:vorax_describe_verbose_key . " <Plug>VoraxDescribeVerbose"
  endif
  let mapdesc = maparg(g:vorax_describe_key, 'v', 0, 1)
  if g:vorax_describe_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "xmap <silent> <unique> <buffer>" . g:vorax_describe_key . " :call vorax#Describe(voraxlib#utils#SelectedBlock(), 0)<cr>"
  endif
  let mapdesc = maparg(g:vorax_describe_verbose_key, 'v', 0, 1)
  if g:vorax_describe_verbose_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "xmap <silent> <unique> <buffer>" . g:vorax_describe_verbose_key . " :call vorax#Describe(voraxlib#utils#SelectedBlock(), 1)<cr>"
  endif

  " oradoc mappings
  let mapdesc = maparg(g:vorax_oradoc_undercursor_key, 'n', 0, 1)
  if g:vorax_oradoc_undercursor_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "noremap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer> " . g:vorax_oradoc_undercursor_key . " :call voraxlib#oradoc#Search(expand('<cword>'))<cr>"
  endif
  let mapdesc = maparg(g:vorax_oradoc_undercursor_key, 'v', 0, 1)
  if g:vorax_oradoc_undercursor_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "xnoremap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer>" . g:vorax_oradoc_undercursor_key . " :call voraxlib#oradoc#Search(voraxlib#utils#SelectedBlock())<cr>"
  endif

endfunction"}}}

" Create a new sql scratch buffer to try on various sql statements.
function! vorax#NewSqlScratch()"{{{
  silent! call voraxlib#utils#FocusCandidateWindow()
  if exists('s:scratch_no')
  	let s:scratch_no += 1
  else
    let s:scratch_no = 1
  endif
  silent! exe 'edit ' . '__scratch' . string(s:scratch_no) . '__.sql'
  let l:template_file = g:vorax_home_dir . '/template_scratch.sql'
  if filereadable( l:template_file)
    exe '0read ' . l:template_file
    normal! G
  endif
  setlocal hidden
  setlocal noswapfile
  setlocal buftype=nowrite
  setlocal noreadonly
  setlocal nowrap
  setlocal nomodified
endfunction"}}}

" Aborts the execution of the current statement.
function! vorax#CancelExec()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN s:CancelExec()') | endif
  let sqlplus = vorax#GetSqlplusHandler()
  let output_window = vorax#GetOutputWindowHandler()
  if sqlplus.IsBusy()
    if !sqlplus.Cancel('Please wait. Aborting...')
      if s:log.isWarnEnabled() | call s:log.warn('Could not cancel on this platform! Reconnect is needed.') | endif
      call voraxlib#utils#Warn("Can not gracefully cancel the currently executing statement on your current OS platform.\n")
      let response = voraxlib#utils#PickOption(
            \ 'Do you want to abort this session? (if yes, reconnect is needed)',
            \ ['(Y)es', '(N)o'])
      if response == 'Y'
        if s:log.isDebugEnabled() | call s:log.debug('User opts for aborting the session.') | endif
        call vorax#ResetSqlplusHandler()
      else
        if s:log.isDebugEnabled() | call s:log.debug('User opts to NOT abort the session.') | endif
      	redraw
      	return
      endif
    endif
    if getline('.') != ""
      " if the last line is not empty then it means we are just in the middle
      " of the output of the last cancelled statement. Let's add 2 empty lines
      " so that the next executed command to nicelly appear below the
      " cancelled one.
      call output_window.AppendText("\n\n")
    endif
    call output_window.AppendText("\n*** Cancelled ***\n")
    call output_window.StopMonitor()
    redraw
    echon "Done!"
  else
    if s:log.isWarnEnabled() | call s:log.warn('You want to cancel what?') | endif
  	call voraxlib#utils#Warn("Nothing to cancel!")
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END s:CancelExec') | endif
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
  normal! gg"_dG
  call append(0, a:content)
  setlocal nomodified
  normal! gg
endfunction"}}}

"}}}

let &cpo=s:cpo_save
unlet s:cpo_save

