" Description: Logging for VoraX.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_logger")
 finish
endif

let g:_loaded_voraxlib_logger = 1
let s:cpo_save = &cpo
set cpo&vim

" A dummy logger object. It is used only if the log.vim script was not 
" installed.
let s:fake_logger = {}

" Fake logger methods. {{{
function! s:fake_logger.log(level, args)
endfunction

function! s:fake_logger.trace(...)
endfunction

function! s:fake_logger.debug(...)
endfunction

function! s:fake_logger.info(...)
endfunction

function! s:fake_logger.warn(...)
endfunction

function! s:fake_logger.error(...)
endfunction

function! s:fake_logger.fatal(...)
endfunction

function! s:fake_logger.isTraceEnabled()
  return 0
endfunction

function! s:fake_logger.isDebugEnabled()
  return 0
endfunction

function! s:fake_logger.isInfoEnabled()
  return 0
endfunction

function! s:fake_logger.isWarnEnabled()
  return 0
endfunction

function! s:fake_logger.isErrorEnabled()
  return 0
endfunction

function! s:fake_logger.isFatalEnabled()
  return 0
endfunction "}}}

" Returns a reference to a new logger object taking as argument the
" originating script where the logging is going to take place.
function! voraxlib#logger#New(script_name)
  if exists("*log#init") && g:vorax_debug_level != 'NONE'
    " Great! vim.log is installed. Just use it!
    let log = log#getLogger(a:script_name)
  else
  	" vim.log is not installed. Use the fake logger.
  	let log = copy(s:fake_logger)
  endif
  return log
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

