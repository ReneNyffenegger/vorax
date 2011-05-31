" Description: Connections management for VoraX.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_connection")
 finish
endif

let g:_loaded_voraxlib_connection = 1
let s:cpo_save=&cpo
set cpo&vim

" Given an a:cstr it asks the user for the missing parts (e.g. password,
" database etc.)
function! voraxlib#connection#Ask(cstr)
  let cstr = a:cstr
  let profiles_manager = vorax#GetProfilesHandler()
  if cstr == ''
    " no connection string was provided. Ask the user.
    let cstr = input('User: ')
    if cstr == ''
      " if no string is provided then exit
      return ''
    endif
  endif
  let cdata = voraxlib#parser#constring#Split(cstr)
  if cdata.user != '' && cdata.db != '' && cdata.passwd == ''
    " enough info to lookup for a stored profiles
    let profile_name = profiles_manager.ExtractProfileNameFromCdata(cdata)
    let cstr_from_profile = profiles_manager.GetConnectionString(profile_name)
    if cstr_from_profile != ''
      let cstr = cstr_from_profile
      let cdata = voraxlib#parser#constring#Split(cstr)
    endif
  endif
  if cdata.passwd == ''
    " prompt for password
    let cdata.passwd = inputsecret('Password: ')
    if cdata.passwd == ''
      " if no string is provided then exit
      return ''
    endif
  endif
  if cdata.db == ''
    " prompt for the target database
    let cdata.database = input('Database: ')
    if cdata.db == ''
      " if no string is provided then exit
      return ''
    endif
  endif
  return voraxlib#connection#CdataToCstr(cdata)
endfunction

" Given a cdata object it returns the corresponding connection string.
function! voraxlib#connection#CdataToCstr(cdata)
  let cstr = a:cdata['user'] . (a:cdata['passwd'] != '' ? '/' . a:cdata['passwd'] : '')
  if a:cdata['osauth']
    let cstr .= " " . a:cdata['db']
  else
    let cstr .= "@" . a:cdata['db']
  endif
  return cstr
endfunction

if exists('s:cpo_save')
  let &cpo=s:cpo_save
  unlet s:cpo_save
endif
