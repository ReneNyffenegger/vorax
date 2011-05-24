" Description: VoraX autoload buddy.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

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
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN vorax#Exec(' . string(a:command) . ')') | endif
  " save the last command. this is require in order to be able to replay it.
  let sqlplus.last_stmt = a:command
  " exec the command in bg, prefixed with a CR. this is important especially
  " in connection with set echo on.
  call sqlplus.NonblockExec(sqlplus.Pack(sqlplus.last_stmt, {'include_eor' : 1}), 0)
  call s:output.StartMonitor()
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

function! vorax#ExecWithHtmlOutput(command)
  let sqlplus = vorax#GetSqlplusHandler()
  let ow = vorax#GetOutputWindowHandler()
  let ofile = fnamemodify(sqlplus.GetRunDir() . '/' . 'output.html', ':8')
  call delete(ofile)
  let command = "spool " . ofile . "\n" . a:command . "\nspool off\n"
  call sqlplus.Exec(sqlplus.Pack(command), 
        \ { 'executing_msg'   : 'Executing...',
        \   'throbber'        : vorax#GetDefaultThrobber(),
        \   'done_msg'        : 'Done.',
        \   'sqlplus_options' : [ {'option' : 'markup', 'value' : 'html on spool on entmap on preformat off'} ] })
  call ow.Focus()
  exe ':$!links -dump ' . ofile
  call ow.AppendText("\n")
endfunction

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

