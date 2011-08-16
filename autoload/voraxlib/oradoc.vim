" Description: The Vorax oradoc feature.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_oradoc") 
 finish
endif

let g:_loaded_voraxlib_oradoc = 1
let s:cpo_save = &cpo
set cpo&vim

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" Create the index for the HTML index.
function! voraxlib#oradoc#CreateIndex(...)"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN voraxlib#oradoc#CreateIndex()') | endif
  if !exists('a:1')
    " default location
    let oradoc_dir = g:vorax_oradoc_target_folder
  else
    let oradoc_dir = a:1
  endif
  let sqlplus = vorax#GetSqlplusHandler()
  let swish_cmd = "swish-e -f " . shellescape(sqlplus.ConvertPath(g:vorax_oradoc_index_file)) . 
                \ " -c " . shellescape(sqlplus.ConvertPath(g:vorax_oradoc_config_file)) . 
                \ " -i " . shellescape(sqlplus.ConvertPath(oradoc_dir))
  if s:log.isDebugEnabled() | call s:log.debug(swish_cmd) | endif
  exe "!" . swish_cmd
  if s:log.isTraceEnabled() | call s:log.trace('END voraxlib#oradoc#CreateIndex()') | endif
endfunction"}}}

" search into the indexes oracledoc for the provided pattern
function voraxlib#oradoc#Search(pattern)"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN voraxlib#oradoc#Search(' . string(a:pattern) . ')') | endif
  let pattern = a:pattern
  if empty(a:pattern)
    let pattern = input('Oradoc Search: ')
    if empty(pattern)
    	" exit if no pattern was provided
    	return
    endif
  endif
  let sqlplus = vorax#GetSqlplusHandler()
  let swish_cmd = "swish-e -f " . shellescape(sqlplus.ConvertPath(g:vorax_oradoc_index_file)) . 
                \ " -H0 " . 
                \ " -x " . shellescape('|%t| in "<doctitle>" => %p\n') .
                \ " -w " . shellescape(pattern)
  let output = system(swish_cmd)
  if s:log.isDebugEnabled() | call s:log.debug(swish_cmd) | endif
  if v:shell_error == 0
    " remove the redundant Oracle(R)... shrink the line and the output is easier to read
    let output = substitute(output, '\"\@<=\(Oracle. \)', '', 'g')
    " remove \r, if any
    let output = substitute(output, '\r', '', 'g')
    let docwin = vorax#GetDocwinHandler()
    " populate the model with the corresponding doc links
    let output_list = split(output, '\n')
    if s:log.isDebugEnabled() | call s:log.debug(string(output_list)) | endif
    if len(output_list) > 0
      call docwin.Populate(output_list)
    else
      call voraxlib#utils#Warn('No help available.')
    endif
  else
    call voraxlib#utils#Warn('Search error. Please check the logs for additional details.')
  endif
endfunction"}}}

let &cpo = s:cpo_save
unlet s:cpo_save
