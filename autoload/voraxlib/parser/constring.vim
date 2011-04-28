" Description: Parsing utilities for connection strings.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0
"
" This function is used to parse a connect string. It receives
" a string like 'user/pwd@db' and it breaks it down into the
" corresponding user,pwd,db parts. It returns these components
" into a dictionary structure: 
"   {'user': , 'passwd': , 'db': , 'osauth': }
" The osauth flag is set if the provided connection string is 
" requesting an OS authentication (e.g. / as sysdba).
function! voraxlib#parser#constring#Split(cstr) 
  " parse the connect string
  let conn_str = a:cstr
  let cdata = {'user': '', 'passwd': '', 'db': '', 'osauth' : 0}
  " find the position of the first unquoted @
  let arond_pos = match(conn_str, '@\([^\"]*"\([^"]\|"[^"]*"\)*$\)\@!', 1, 1)
  " find the position of the first unquoted /
  let slash_pos = match(conn_str, '\/\([^\"]*"\([^"]\|"[^"]*"\)*$\)\@!', 1, 1)
  if arond_pos >= 0
    " we have the database specified
    let cdata['db'] = toupper(strpart(conn_str, arond_pos + 1, strlen(conn_str)))
    let conn_str = strpart(conn_str, 0, arond_pos)
  endif
  if slash_pos >= 0
    " we have the username and the password specified
    let cdata['user'] = strpart(conn_str, 0, slash_pos)
    let cdata['passwd'] = strpart(conn_str, slash_pos + 1, strlen(conn_str))
  else
    " if no slash then everything before @ is asumed to be the user
    let cdata['user'] = conn_str
  endif
  " trim leading/trailing spaces from cdata
  for key in keys(cdata)
    if key != 'osauth'
      let cdata[key] = substitute(cdata[key],'^\s\+\|\s\+$',"","g")
    endif
  endfor
  " check for OS auth
  if cdata['db'] == '' || cdata['db'] =~? '^\s*as\s*(sysdba|sysasm|sysoper)\s*$'
    let cdata['osauth'] = 1
  endif
  return cdata
endfunction

