" Description: Implements the VoraX oradoc panel/window.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_panel_docwin") 
 finish
endif

let g:_loaded_voraxlib_panel_docwin = 1
let s:cpo_save = &cpo
set cpo&vim
  
" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" Creates the oradoc window. Only one such object instance is allowed in a
" VoraX instance. It expects the following parameters:
"   a:split_type => 'v' for vertical; 'h' for horizontal
"   a:orientation => 'topleft' or 'bottomright'
"   a:size => the size of the window. For horizontal ones it refers to the
"   height, for the vertical ones to the width
function! voraxlib#panel#docwin#New()"{{{
  if !exists('s:docwin_window')
    " No docwin window has been initialized. Create it now.
    let s:docwin_window = voraxlib#widget#window#New('__VoraxOradoc__', 
          \ g:vorax_oradoc_window_orientation,
          \ g:vorax_oradoc_window_anchor, 
          \ g:vorax_oradoc_window_size,
          \ 0)
    " Add additional functionality
    call s:ExtendWindow()
  endif
  return s:docwin_window
endfunction"}}}

" Create additional functionality
function! s:ExtendWindow()"{{{
  
  " Overwrite the configure method
  function! s:docwin_window.Configure() dict"{{{
    setlocal hidden
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal nonu
    setlocal cursorline
    setlocal bufhidden=delete
    setlocal nolist
    setlocal foldcolumn=0 nofoldenable
    setlocal noreadonly
    setlocal nobuflisted
    setlocal isk+=$
    setlocal isk+=#
    setlocal filetype=voraxdoc

    call s:docwin_window.LockBuffer()

    noremap <silent> <buffer> <cr> :call <SID>OpenLink()<cr>
    noremap <silent> <buffer> o :call <SID>OpenLink()<cr>
    noremap <silent> <buffer> q :close<cr>
  
  endfunction"}}}

  " Populate the docwin with the search result
  function! s:docwin_window.Populate(lines)
    call self.Focus()
    call self.UnlockBuffer()
    " delete everything with nothing saved in registers
    normal gg"_dG
    call append(0, a:lines)
    call self.LockBuffer()
    normal gg
  endfunction

endfunction"}}}

function! s:OpenLink()
  let sqlplus = vorax#GetSqlplusHandler()
  let link = sqlplus.ConvertPath(substitute(getline('.'), '^.*=> ', '', ''))
  " no backslashes please
  let link = substitute(link, '\\', '/', 'g')
  let cmd = substitute(g:vorax_oradoc_open_with, '%u', link, 'g')
  if s:log.isDebugEnabled() | call s:log.debug(cmd) | endif
  exe cmd
  " redraw vim. sometimes the launched external browser mess up vim
  redraw!
  if g:vorax_oradoc_window_autoclose
  	close!
  endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
