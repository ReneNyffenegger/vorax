" Description: Implements the VoraX output panel/window.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo = &cpo
set cpo-=C

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

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
function! s:ExtendWindow()"{{{

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
    setlocal bufhidden=delete
    setlocal nolist
    setlocal foldcolumn=0 nofoldenable
    setlocal noreadonly
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
    if g:vorax_output_window_keep_focus_after_exec
      " register an autocommand to the originating buffer. This has to be done
      " now because after stopping the monitor the originating window will not
      " be focused
      call s:RegisterClearHighlight()
    else
      let s:originating_window = winnr()
    endif
    call self.Focus()
    "if g:vorax_inline_prompt
      "inoremap <buffer> <cr> <esc>:call <SID>ProcessUserInput()<cr>
    "else
      "nmap <buffer> <cr> :call <SID>ProcessUserInput()<cr>
    "endif
    noremap <buffer> <esc> :call <SID>CancelExec()<cr>
    au VoraX CursorHold <buffer> call s:FetchResults()
    call feedkeys("f\e")  
  endfunction"}}}

  " Stop the monitor for the output window.
  function s:output_window.StopMonitor()"{{{
    call self.Focus()
    "mapclear <buffer>
    "imapclear <buffer>
    "" still, the registered keys should remain
    "call s:RegisterKeys()
    au VoraX CursorHold <buffer> call s:FetchResults()
    autocmd! VoraX CursorHold <buffer>
    if !g:vorax_output_window_keep_focus_after_exec
      " restore focus to the originating window
      exe s:originating_window.'wincmd w'
      " register the clear highlight action.
      call s:RegisterClearHighlight()
    endif
  endfunction"}}}

endfunction"}}}

" This function is called repeatably in order to fetch the results and to show
" them within the output window.
function! s:FetchResults()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let chunk = sqlplus.Read()
  " spit the results
  call s:output_window.AppendText(chunk)
  " simulate a key press in order to fire the CursorHold auto command.
  call feedkeys("f\e")  
  " if that's the last chunk of data which also means the command has
  " finished.
  if !sqlplus.IsBusy()
    " Great! The executing statement has just finished!
  	call s:output_window.StopMonitor()
    echon 'Done.'
  else
    " feedback to the user please.
    call s:UpdateThrobber('Executing...', vorax#GetDefaultThrobber())
  endif
endfunction"}}}

" Update throbber.
function! s:UpdateThrobber(msg, throbber)"{{{
  redraw
  echon a:msg . ' '. a:throbber.Spin()
  "let &titlestring=a:msg . ' '. a:throbber.Spin()
endfunction"}}}

" Registers an autocommand for the current buffer to clear any highlighting
" when the cursor moves. This is done only if it's an oracle sql buffer and a
" highlight group was setup.
function! s:RegisterClearHighlight()"{{{
  if voraxlib#utils#IsSqlOracleBuffer() &&
        \ voraxlib#utils#IsHighlightEnabled()
    " store the current cursor position
    let [s:crr_l, s:crr_c] = [line('.'), col('.')]
    au VoraX CursorHold <buffer> call s:ClearHighlight()
  endif
endfunction"}}}

" This function is internally called from an autocommand in order to clear the
" highlighting of the current executed SQL statement.
function! s:ClearHighlight()"{{{
  if (exists('s:crr_l') && exists('s:crr_c')) && 
        \ (line('.') != s:crr_l || col('.') != s:crr_c)
    " only if the cursor was really moved. This event is quite impredictible
    " and may be triggered by other plugins.
    match none
    au! VoraX CursorHold <buffer>
    unlet s:crr_l
    unlet s:crr_c
  endif
endfunction"}}}

" Aborts the execution of the current statement.
function! s:CancelExec()
  let sqlplus = vorax#GetSqlplusHandler()
  if sqlplus.IsBusy()
    if !sqlplus.Cancel()
      call voraxlib#utils#Warn("Could not gracefully cancel the currently executing statement.\n".
            \ "You must reconnect!")
    endif
    call s:output_window.StopMonitor()
    if getline('.') != ""
      " if the last line is not empty then it means we are just in the middle
      " of the output of the last cancelled statement. Let's add 2 empty lines
      " so that the next executed command to nicelly appear below the
      " cancelled one.
      call s:output_window.AppendText("\n\n")
    endif
    redraw
    echon "Done!"
  else
  	call voraxlib#utils#Warn("Nothing to cancel!")
  endif
endfunction

let &cpo=s:cpo
unlet s:cpo
