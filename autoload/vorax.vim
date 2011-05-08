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
  call s:log.trace('BEGIN vorax#Connect(' . string(a:cstr) . ')')
  if s:sqlplus.GetPid() && a:bang == '!'
    " destroy the sqlplus process if any attached
    call s:log.debug('Connect with bang. Destroy the old attached sqlplus process.')
    call s:sqlplus.Destroy()
    let s:sqlplus = voraxlib#sqlplus#New()
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
        call s:output.AppendText(s:sqlplus.GetBanner())
        call s:output.AppendText(output)
      endif
    else
      echo 'Aborted!'
    endif
  endif
  call s:log.trace("END vorax#Connect")
endfunction"}}}

function! vorax#Exec(command)
  call s:log.trace('BEGIN vorax#Exec(' . string(a:command) . ')')
  " exec the command in bg, prefixed with a CR. this is important especially
  " in connection with set echo on.
  call s:sqlplus.NonblockExec(s:sqlplus.Pack(a:command))
  call s:output.StartMonitor()
  call s:log.trace('END vorax#Exec')
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
  return s:sqlplus
endfunction"}}}

" Get the default throbber
function! vorax#GetDefaultThrobber()
  return s:default_throbber
endfunction

" Get the output window object.
function! vorax#GetOutputWindowHandler()"{{{
  return s:output
endfunction"}}}

