" Description: Implements the VoraX output panel/window.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo = &cpo
set cpo-=C

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" The lines to be removed by the RemoveHead function.
let s:head_lines = []

" Creates a new output window. Only one such object instance is allowed in a
" VoraX instance. It expects the following parameters:
"   a:split_type => 'v' for vertical; 'h' for horizontal
"   a:orientation => 'topleft' or 'bottomright'
"   a:size => the size of the window. For horizontal ones it refers to the
"   height, for the vertical ones to the width
function! voraxlib#panel#output#New()"{{{
  if !exists('s:output_window')
    " No output window has been initialized. Create it now.
    let s:output_window = voraxlib#widget#window#New('__VoraxOutput__', 
          \ g:vorax_output_window_orientation,
          \ g:vorax_output_window_anchor, 
          \ g:vorax_output_window_size,
          \ 1)
    " Add additional functionality
    call s:ExtendWindow()
  endif
  return s:output_window
endfunction"}}}

" This functions exend the base window widget with methods
" specific to the output window.
function! s:ExtendWindow()

  " Overwrite the configure method
  function! s:output_window.Configure() dict"{{{
    setlocal hidden
    setlocal updatetime=50
    setlocal winfixheight
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nospell
    setlocal nonu
    setlocal cursorline
    setlocal modifiable
  endfunction"}}}

  " Write the provided text at the end of the output window. If 
  " multiple lines has to be appended then provide the
  " a:text parameter as an array.
  function! s:output_window.AppendText(text) dict"{{{
    if !self.HasFocus()
      " focus the window if not active
      call self.Focus()
    endif
    let lines_no = line('$')
    let last_line = getline(lines_no)
    let lines = split(a:text, '\(\r\n\)\|\(\r\)\|\(\n\)', 1)
    if len(lines) > 0
      call setline(lines_no, last_line . lines[0])
      call remove(lines, 0)
      if len(lines) > 0
        call append(lines_no, lines)
      endif
    endif
    normal G
  endfunction"}}}

  " Clear the output window.
  function! s:output_window.Clear() dict"{{{
    call self.Focus()
    " delete everything with nothing saved in registers
    normal gg"_dG
  endfunction"}}}

  function! s:output_window.StartMonitor()"{{{
    let s:start_time = localtime()
    call self.Focus()
    "if g:vorax_inline_prompt
      "inoremap <buffer> <cr> <esc>:call <SID>ProcessUserInput()<cr>
    "else
      "nmap <buffer> <cr> :call <SID>ProcessUserInput()<cr>
    "endif
    "nmap <buffer> <c-c> :call <SID>CancelExec()<cr>
    au VoraX CursorHold <buffer> call s:FetchResults()
    let s:head_lines = [1, 2]
    call feedkeys("f\e")  
  endfunction"}}}

  " Stop the monitor for the output window.
  function s:output_window.StopMonitor()"{{{
    call self.Focus()
    "mapclear <buffer>
    "imapclear <buffer>
    "" still, the registered keys should remain
    "call s:RegisterKeys()
    let s:head_lines = []
    au VoraX CursorHold <buffer> call s:FetchResults()
    autocmd! VoraX CursorHold <buffer>
  endfunction"}}}

endfunction

" This function is called repeatably in order to fetch the results and to show
" them within the output window.
function! s:FetchResults()
  let sqlplus = vorax#GetSqlplusHandler()
  let chunk = sqlplus.Read()
  if chunk != '' && len(s:head_lines) > 0
    "get rid of the first line. This first line is the command sent to the
    "sqlplus process but is not echoed. However, the sqlprompt is shown and is
    "messing up the output, therefore it's better to simply remove that line.
    let new_chunk = s:RemoveHead(chunk)
    if new_chunk != chunk
      let chunk = new_chunk
      let s:first = 0
    endif
  end
  if !sqlplus.IsBusy()
    " get rid of the last line. The last line is the sqlprompt waiting for new
    " commands to be inputed. That's ugly and the output looks much better
    " without it.
    let chunk = s:RemoveTail(chunk)
  endif
  " spit the results
  call s:output_window.AppendText(chunk)
  " simulate a key press in order to fire the CursorHold auto command.
  call feedkeys("f\e")  
  " if that's the last chunk of data which also means the command has
  " finished.
  if !sqlplus.IsBusy()
    " add an empty line at the end
    call s:output_window.AppendText("\n")
  	call s:output_window.StopMonitor()
    echon 'Done.'
  else
    " feedback to the user please.
    call s:UpdateThrobber('Executing...', vorax#GetDefaultThrobber())
  endif
endfunction

" Update throbber.
function! s:UpdateThrobber(msg, throbber)"{{{
  redraw
  echon a:msg . ' '. a:throbber.Spin()
  "let &titlestring=a:msg . ' '. a:throbber.Spin()
endfunction"}}}

" Remove the first two lines from the provided chunk of text. This function is
" used to pretty print the text to be shown within the output window.
function! s:RemoveHead(chunk)"{{{
  call s:log.trace('BEGIN s:RemoveHead(' . string(a:chunk) . ')')
  let result = a:chunk
  for i in copy(s:head_lines)
    let first_cr = stridx(result, "\n")
    if first_cr == -1
    	break
    endif
    let result = strpart(result, first_cr + 1, len(result))
    call remove(s:head_lines, 0)
  endfor
  call s:log.trace('END s:RemoveHead => '. string(result))
  return result
endfunction"}}}

" Remove the last two lines from the provided chunk of text. This function is
" used to pretty print the text to be shown within the output window.
function! s:RemoveTail(chunk)"{{{
  call s:log.trace('BEGIN s:RemoveTail(' . string(a:chunk) . ')')
  let result = a:chunk
  for i in [1, 2]
    let first_cr = strridx(result, "\n")
    if first_cr == -1
    	break
    endif
    let result = strpart(result, 0, first_cr)
  endfor
  call s:log.trace('END s:RemoveTail => '. string(result))
  return result
endfunction"}}}

let &cpo=s:cpo
unlet s:cpo
