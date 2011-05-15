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

    " define mappings
    if exists('g:vorax_output_window_clear_key') && g:vorax_output_window_clear_key != ''
      exe 'nnoremap <buffer> ' . g:vorax_output_window_clear_key . ' :call <SID>ClearOutputWindow()<cr>'
    endif
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
    au VoraX CursorHold <buffer> call s:FetchResults()
    call s:SetupInteractivity()
  endfunction"}}}

  " Stop the monitor for the output window.
  function s:output_window.StopMonitor()"{{{
    call self.Focus()
    au VoraX CursorHold <buffer> call s:FetchResults()
    autocmd! VoraX CursorHold <buffer>
    call s:RemoveInteractivity()
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
  if chunk != ""
    call s:output_window.AppendText(chunk)
  endif
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
    call s:UpdateThrobber('Executing... Press <esc> to cancel.', vorax#GetDefaultThrobber())
  endif
endfunction"}}}

" Update throbber.
function! s:UpdateThrobber(msg, throbber)"{{{
  redraw
  echon a:msg . ' '. a:throbber.Spin()
  "let &titlestring=a:msg . ' '. a:throbber.Spin()
endfunction"}}}

" This function prepares the output window for interactivity like: respond to
" ACCEPT sqlplus commands, prompting for values etc.
function! s:SetupInteractivity()"{{{
  au VoraX InsertEnter <buffer> call s:PrepareInsertMode()
  au VoraX CursorMovedI <buffer> call s:EnforceAnchor()
  " define special mappings
  noremap <buffer> <esc> :call <SID>CancelExec()<cr>
  inoremap <buffer> <cr> <esc>:call <SID>ProcessUserInput()<cr>
endfunction"}}}

" Remove the interactivity features.
function! s:RemoveInteractivity()"{{{
  " remove autocommands
  au! VoraX InsertEnter <buffer>
  au! VoraX CursorMovedI <buffer>
  " remove keys
  let map = maparg('<esc>', 'n', 0, 1)
  if has_key(map, 'buffer') && map.buffer == 1
    unmap <buffer> <esc>
  endif
  let map = maparg('<cr>', 'i', 0, 1)
  if has_key(map, 'buffer') && map.buffer == 1
    iunmap <buffer> <cr>
  endif
  if exists('s:anchor')
  	unlet s:anchor
  endif
endfunction"}}}

" This function is used to get what the user inputed in the output window and
" to send that text to the sqlplus process.
function! s:ProcessUserInput()"{{{
  let val = strpart(getline('.'), s:anchor[1] - 2)
  if s:log.isDebugEnabled() | call s:log.debug('s:ProcessUserInput(): val=' .string(val)) | endif
  call s:output_window.AppendText("\n")
  call vorax#GetSqlplusHandler().SendText(val . "\n")
  stopinsert
endfunction"}}}

" Registers an autocommand for the current buffer to clear any highlighting
" when the cursor moves. This is done only if it's an oracle sql buffer and a
" highlight group was setup.
function! s:RegisterClearHighlight()"{{{
  if voraxlib#utils#IsSqlOracleBuffer() &&
        \ voraxlib#utils#IsHighlightEnabled()
    " store the current cursor position
    let [s:crr_l, s:crr_c] = [line('.'), col('.')]
    if s:log.isDebugEnabled() | call s:log.debug('s:RegisterClearHighlight(): [s:crr_l, s:crr_c]=' .string([s:crr_l, s:crr_c])) | endif
    au VoraX CursorMoved <buffer> call s:ClearHighlight()
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
    au! VoraX CursorMoved <buffer>
    unlet s:crr_l
    unlet s:crr_c
  endif
endfunction"}}}

" Aborts the execution of the current statement.
function! s:CancelExec()"{{{
  if s:log.isTraceEnabled() | call s:log.trace('BEGIN s:CancelExec()') | endif
  let sqlplus = vorax#GetSqlplusHandler()
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
      call s:output_window.AppendText("\n\n")
    endif
    call s:output_window.StopMonitor()
    redraw
    echon "Done!"
  else
    if s:log.isWarnEnabled() | call s:log.warn('You want to cancel what?') | endif
  	call voraxlib#utils#Warn("Nothing to cancel!")
  endif
  if s:log.isTraceEnabled() | call s:log.trace('END s:CancelExec') | endif
endfunction"}}}

" This function is invoked by the clear window mapping.
function! s:ClearOutputWindow()"{{{
  call s:output_window.Clear()
endfunction"}}}

" This function is called by an CursorHoldI autocommand in order to force the
" user to insert text at the end of the buffer.
function! s:ForceInsertAtTheEnd()
  call s:SetCursorAtTail()
  au! VoraX CursorHoldI <buffer>
endfunction

" This function is invokde by an autocommand before entering in insert mode.
" It places the cursor at the end of the buffer and remember this position.
function! s:PrepareInsertMode()"{{{
  if line('.') == line('$') && col('.') == col('$')
    " it's okey
  else
    " register an autoevent to exit from the insert mode
    au VoraX CursorHoldI <buffer> call s:ForceInsertAtTheEnd()
  endif
  " save this position in order to be able to prohibit the user to change the
  " buffer beyond this anchor.
  let [ll, lc] = [line('$'), len(getline('$'))]
  let s:anchor = [ll, lc+1, strpart(getline('$'), 0, lc+1)]
  " remap the <esc> mapping in order to discard the inputed text in case the
  " user press <esc>
  inoremap <buffer> <esc> <C-o>:call <SID>CancelPrompt()<cr>
  redraw
  echo 'Enter the value sqlplus asks for...'
endfunction"}}}

" Discards what the user entered at the sqlplus ACCEPT prompt.
function! s:CancelPrompt()"{{{
  echom 'a intrat'
  stopinsert
  " restore the old prompt
  if exists('s:anchor')
    call setline(s:anchor[0], s:anchor[2])
  endif
  " restore the default <esc> mapping
  iunmap <buffer> <esc>
endfunction"}}}

" This function place the cursor at the end of the last line. It is invoked by
" the InsertEnter autocmd.
function! s:SetCursorAtTail()"{{{
  call setpos('.', [bufnr('%'), line('$'), 0, 0])
  call setpos('.', [bufnr('%'), line('$'), col('$') + 2, 0])
endfunction"}}}

" This function is invoked by the CursorMovedI autocommand and prohibits the
" user to move the cursor beyond the current prompter.
function! s:EnforceAnchor()"{{{
  if exists('s:anchor') &&
        \ (line('.') < s:anchor[0] || col('.') < s:anchor[1] - 1)
    call s:SetCursorAtTail()
    let line = getline('.')
    let tail = strpart(line, col('.'))
    if strpart(line, 0, s:anchor[1]) != s:anchor[2]
      let line = s:anchor[2] . tail
      call setline(s:anchor[0], line)
    endif
    call s:SetCursorAtTail()
  endif
endfunction"}}}

let &cpo=s:cpo
unlet s:cpo
