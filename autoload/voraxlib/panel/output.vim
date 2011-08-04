" Description: Implements the VoraX output panel/window.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_panel_output") 
 finish
endif

let g:_loaded_voraxlib_panel_output = 1
let s:cpo_save = &cpo
set cpo&vim
  
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
    " Status info
    let s:output_window['status'] = ''
    " The output buffer.
    let s:output_window['buffer'] = { 'text' : '', 'html' : 0, 'vertical' : 0 } 
    " Spooling flag.
    let s:output_window['spooling'] = 0
    " Log destination.
    let s:output_window['spool_file'] = ''
    " Add additional functionality
    call s:ExtendWindow()
  endif
  return s:output_window
endfunction"}}}

" Returns the status line format for the output window.
function! voraxlib#panel#output#StatusLine()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  return ' %l/%v - %P%= '.
        \ (exists('g:vorax_limit_rows') && g:vorax_limit_rows > 0 ? 'limit=' . string(g:vorax_limit_rows) . ' ' : '') .
        \ (s:IsPaginatingEnabled() ? 'pause=' . (g:vorax_output_window_page_size == 0 ? 'auto' : string(g:vorax_output_window_page_size)) . ' ' : '') .
        \ (sqlplus.html && !s:output_window.buffer.vertical ? 'compressed ' : '') . 
        \ (sqlplus.html && s:output_window.buffer.vertical ? 'vertical ' : '') . 
        \ (s:output_window.spooling ? '[spool to: ' . simplify(s:output_window.spool_file) . '] ' : '') . 
        \ (exists('g:vorax_monitor_end_exec') && g:vorax_monitor_end_exec ? 'bell ' : '' ) . 
        \ sqlplus.GetConnectedTo() . ' '
endfunction"}}}

" This functions exend the base window widget with methods
" specific to the output window.
function! s:ExtendWindow()"{{{

  " Overwrite the configure method
  function! s:output_window.Configure() dict"{{{
    setlocal hidden
    setlocal updatetime=50
    "setlocal winfixheight
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
    setlocal nobuflisted
    setlocal isk+=$
    setlocal isk+=#
    exe 'setlocal statusline=' . g:vorax_output_window_statusline

    " define mappings
    if exists('g:vorax_output_window_clear_key') && g:vorax_output_window_clear_key != ''
      exe 'nnoremap <silent> <buffer> ' . g:vorax_output_window_clear_key . ' :call <SID>ClearOutputWindow()<cr>'
    endif
  endfunction"}}}

  " Write the provided text at the end of the output window. If 
  " multiple lines has to be appended then provide the
  " a:text parameter as an array.
  function! s:output_window.AppendText(text, ...) "{{{
    if !self.HasFocus()
      " focus the window if not active
      call self.Focus()
    endif
    if exists('a:1') && a:1 == 1
      echom 'a intrat'
      call self.Clear()
    endif
    let lines_no = line('$')
    let last_line = getline(lines_no)
    " get rid of CRs
    let text = substitute(a:text, '\r', '', 'g')
    let lines = split(text, '\n', 1)
    if len(lines) > 0
      call setline(lines_no, last_line . lines[0])
      call remove(lines, 0)
      if len(lines) > 0
        call append(lines_no, lines)
      endif
    endif
    normal G
  endfunction"}}}

  " Append the provided text to the output buffer.
  function! s:output_window.PushToBuffer(text, html)"{{{
    if a:text != ''
      let self.buffer.text .= a:text
      let self.buffer.html = a:html
    endif
  endfunction"}}}

  " Clear the content of the output buffer.
  function! s:output_window.ClearBuffer()"{{{
    let self.buffer.text = ''
    let self.buffer.html = 0
  endfunction"}}}

  " Pop/retrieve the specified maximum number of lines from the output buffer.
  function! s:output_window.PopFromBuffer(...)"{{{
    if exists('a:1')
      let retval = voraxlib#utils#ExtractLines(self.buffer.text, 1, a:1)
    else
    	let retval = self.buffer.text
    endif
    let self.buffer.text = strpart(self.buffer.text, len(retval))
    return retval
  endfunction"}}}

  " Convert the buffer content from html to text.
  function! s:output_window.CompressHtmlBuffer()"{{{
    if self.buffer.html
      redraw
      echo 'Compressing output...'
      if s:log.isDebugEnabled() | call s:log.debug('html buffer: '.string(self.buffer.text)) | endif
      let self.buffer.text = voraxlib#parser#output#Compress(self.buffer.text, self.buffer.vertical)
      if s:log.isDebugEnabled() | call s:log.debug('after convert: '.string(self.buffer.text)) | endif
      let self.buffer.html = 0
    endif
  endfunction"}}}

  " Clear the output window.
  function! s:output_window.Clear() "{{{
    call self.Focus()
    " delete everything with nothing saved in registers
    normal gg"_dG
  endfunction"}}}

  " Start the monitor for the output window.
  function! s:output_window.StartMonitor()"{{{
    call s:ResetWork()
    let s:originating_window = winnr()
    call self.Focus()
    au VoraX CursorHold <buffer> call s:FetchResults()
    call s:SetupInteractivity()
    let s:old_showcmd = &showcmd
    let &showcmd = 0
  endfunction"}}}

  " Whenever or not the monitor is running
  function! s:output_window.IsMonitorRunning()"{{{
    return exists('s:monitor_running') && s:monitor_running
  endfunction"}}}

  " Stop the monitor for the output window.
  function s:output_window.StopMonitor()"{{{
    call s:ResetWork()
    call self.Focus()
    au VoraX CursorHold <buffer> call s:FetchResults()
    autocmd! VoraX CursorHold <buffer>
    call s:RemoveInteractivity()
    call self.EnsureEmptyLineAtTheEnd()
    if !g:vorax_output_window_keep_focus_after_exec
      " restore focus to the originating window
      exe s:originating_window.'wincmd w'
      let sqlplus = vorax#GetSqlplusHandler()
      if g:vorax_keep_selection_after_exec
        normal gv
      endif
    endif
    let &showcmd = s:old_showcmd
  endfunction"}}}

  " Whenever or not the monitor is paused.
  function! s:output_window.IsMonitorPaused()"{{{
    return exists('s:pause') && s:pause
  endfunction"}}}

  " Start spooling in the provided file
  function! s:output_window.StartSpooling(file)"{{{
    let file = a:file
    if a:file == ''
      " prompt the user for a file
      let file = input('Spool file: ', '', "file")
    endif
    if file != ''
      ruby <<EORC
      begin
        $spool_file = File.open(File.expand_path(VIM::evaluate('file')), 'a')
        VIM::command('let s:output_window.spooling=1')
        VIM::command("let s:output_window.spool_file=#{VIM::evaluate('file').inspect}")
      rescue Errno::ENOENT
        VIM::command("call voraxlib#utils#Warn('The spool file could not be created. Invalid path?')")
      rescue => err
        VIM::command("call voraxlib#utils#Warn('The spool file could not be created.')")
        VIM::command("call voraxlib#utils#Warn(#{err.message.inspect})")
      end
EORC
    else
    endif
  endfunction"}}}

  " Stop spooling.
  function! s:output_window.StopSpooling()"{{{
    ruby <<EORC
    begin
      if defined?($spool_file) && $spool_file
        $spool_file.close
      end
    rescue
      VIM::command("voraxlib#utils#Warn('The spool file could not be closed.')")
    end
EORC
    let self.spooling=0
  endfunction"}}}
  
  " Add an empty line at the end of the output window if the last line is not
  " empty.
  function! s:output_window.EnsureEmptyLineAtTheEnd()"{{{
    " ensure an empty line between execs
    if get(getbufline(self.name, '$'), 0, '') !~ '^\s*$'
      call self.AppendText("\n")
    endif
  endfunction"}}}

endfunction"}}}

" Write text to the spool file.
function! s:WriteToSpool(text)"{{{
  ruby <<EORC
  begin
    $spool_file.print(VIM::evaluate('a:text'))
    $spool_file.flush
  rescue => err
    VIM::command("voraxlib#utils#Warn('Cannot write to spool file.')")
    VIM::command("voraxlib#utils#Warn(#{err.message.inspect})")
    VIM::command("let err=1")
  end
EORC
  if exists('err')
    let response = voraxlib#utils#PickOption(
          \ 'Do you want to stop spooling?',
          \ ['(Y)es', '(N)o'])
    if response == 'Y'
      s:output_window.StopSpooling()
    end
  endif
endfunction"}}}

" Compute the status feedback based on the provided chunk.
function! s:SetStatusFeedback(chunk)"{{{
  if a:chunk != ''
    let s:last_set = localtime()
    let last_line = voraxlib#utils#CountMatch(a:chunk, '\n')
    let s:output_window['status'] .= voraxlib#utils#ExtractLines(a:chunk, last_line + 1)
    let s:output_window['status'] = strpart(substitute(s:output_window['status'], '\(\r\n\)\|\r\|\n', " ... ", "g"), len(s:output_window['status'])-20)
    if s:output_window.buffer.html
      let s:output_window.status = substitute(voraxlib#parser#output#Compress(s:output_window.status, 0), '\(\r\n\)\|\r\|\n', "", "g")
    endif
  endif
  if s:pause
    if exists('g:vorax_output_window_pause_key') && g:vorax_output_window_pause_key != ''
      call s:UpdateFeedback('*** PAUSED ***. Press ' . g:vorax_output_window_pause_key . ' to resume or <Esc> to cancel...')
    else
      call s:UpdateFeedback('*** PAUSED ***')
    end
  else
    if localtime() - s:last_set > 1
      call s:UpdateFeedback('(Waiting in prompt/pause or slow fetch). <CR> to input at prompt = [...' . s:output_window['status'] . ']', vorax#GetDefaultThrobber())
    else
      call s:UpdateFeedback(' Executing...' , vorax#GetDefaultThrobber())
    endif
  endif
endfunction"}}}

" This function is internally used to reset various counters.
function! s:ResetWork()"{{{
  let s:pause = 0
  let s:lines = 0
  let s:monitor_running = 0
  let s:last_set = localtime()
  let s:output_window['status'] = ''
  call s:output_window.ClearBuffer()
endfunction"}}}

" Whenever or not the output window should take care of the paginating.
function! s:IsPaginatingEnabled()"{{{
  return exists('g:vorax_output_window_pause') && g:vorax_output_window_pause
endfunction"}}}

" Read from the output buffer and taking into account pagination it spits the
" corresponding output.
function! s:SpitOutput()"{{{
  if s:IsPaginatingEnabled()
    " only if paginating is configured
    let page_size = (g:vorax_output_window_page_size == 0 ? winheight('.') :
          \ g:vorax_output_window_page_size)
    let lines = s:output_window.PopFromBuffer(page_size - s:lines)
    let s:lines += voraxlib#utils#CountMatch(lines, '\n')
  else
    " get all lines from the buffer
    let lines = s:output_window.PopFromBuffer()
  endif
  " spit the results
  if lines != ""
    call s:output_window.AppendText(lines)
    if s:output_window.spooling
      call s:WriteToSpool(lines)
    endif
    if exists('page_size') && s:lines == page_size
      let s:lines = 0
      let s:pause = 1
    endif
  endif
endfunction"}}}

" This function is called repeatably in order to fetch the results and to show
" them within the output window.
function! s:FetchResults()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let chunk = ''
  if !s:pause
    let chunk = sqlplus.Read()
    call s:output_window.PushToBuffer(chunk, sqlplus.html)
    if sqlplus.html
      " pretty print. do not display anything unless the whole output is
      " obtained.
      if !sqlplus.IsBusy()
        " it's done... pretty print please
        call s:output_window.CompressHtmlBuffer()
        call s:SpitOutput()
      endif
    else
      " normal output
      call s:SpitOutput()
    endif
  endif
  " simulate a key press in order to fire the CursorHold auto command.
  call feedkeys("f\e")  
  " if that's the last chunk of data which also means the command has
  " finished.
  if s:Eof()
    " Great! The executing statement has just finished!
  	call s:output_window.StopMonitor()
    echon 'Done.'
  else
    " feedback to the user please.
    call s:SetStatusFeedback(chunk)
  endif
endfunction"}}}

" Whenever or not the end of output has been reached.
function! s:Eof()"{{{
  if len(s:output_window.buffer.text) > 0
    return 0
  else
    let sqlplus = vorax#GetSqlplusHandler()
    return !sqlplus.IsBusy()
  end
endfunction"}}}

" Update feedback info to the user. An optional throbber may be  provided.
function! s:UpdateFeedback(msg, ...)"{{{
  redraw
  echon (exists('a:1') ? a:1.Spin() . ' ' : '') . a:msg
  "let &titlestring=a:msg . ' '. a:throbber.Spin()
endfunction"}}}

" This function prepares the output window for interactivity like: respond to
" ACCEPT sqlplus commands, prompting for values etc.
function! s:SetupInteractivity()"{{{
  " define special mappings
  noremap <buffer> <silent> <esc> :call <SID>CancelExec()<cr>
  if exists('g:vorax_output_window_pause_key') && g:vorax_output_window_pause_key != ''
    exe 'noremap <buffer> ' . g:vorax_output_window_pause_key . ' :call <SID>TogglePause()<cr>'
  endif
  noremap <buffer> <silent> <cr> <esc>:call <SID>ProcessUserInput()<cr>
endfunction"}}}

" Remove the interactivity features.
function! s:RemoveInteractivity()"{{{
  " remove keys
  let map = maparg('<esc>', 'n', 0, 1)
  if has_key(map, 'buffer') && map.buffer == 1
    unmap <buffer> <esc>
  endif
  if exists('g:vorax_output_window_pause_key') && g:vorax_output_window_pause_key != ''
    let map = maparg(g:vorax_output_window_pause_key, 'n', 0, 1)
    if has_key(map, 'buffer') && map.buffer == 1
      unmap <buffer> <Space>
    endif
  endif
  let map = maparg('<cr>', 'n', 0, 1)
  if has_key(map, 'buffer') && map.buffer == 1
    unmap <buffer> <cr>
  endif
endfunction"}}}

" Toggle PAUSE for the output window.
function! s:TogglePause()"{{{
  let s:pause = !s:pause
endfunction"}}}

" This function is used to get what the user inputed in the output window and
" to send that text to the sqlplus process.
function! s:ProcessUserInput()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  call inputsave()
  let val = input(s:output_window['status'])
  call inputrestore()
  if s:log.isDebugEnabled() | call s:log.debug('s:ProcessUserInput(): val=' .string(val)) | endif
  if sqlplus.html
    " compressed output is active, postpone to the output buffer
    call s:output_window.PushToBuffer(val . "\n<br>", 1)
  else
    " normal output. just put the inputed value to the output window
    call s:output_window.AppendText(val . "\n")
  endif
  call vorax#GetSqlplusHandler().SendText(val . "\n")
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
    call s:output_window.AppendText("\n*** Cancelled ***\n")
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

let &cpo = s:cpo_save
unlet s:cpo_save

