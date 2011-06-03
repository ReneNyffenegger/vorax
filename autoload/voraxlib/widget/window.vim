" Description: Provides an abstraction for a basic window/split widget.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_widget_window") 
 finish
endif

let g:_loaded_voraxlib_widget_window = 1
let s:cpo_save = &cpo
set cpo&vim

let s:window = {
      \ 'name' : '',
      \ 'instance_no' : 0,
      \ 'orientation' : '',
      \ 'anchor' : '',
      \ 'size' : 30,
      \ 'multi_tab' : 0,
      \}

" Creates and returns a new window handler. This function expects the
" following parameters:
"   a:name => the name of the window. Only [a-z] characters are allowed.
"   a:orientation => 'v' for vertical; 'h' for horizontal
"   a:anchor => 'topleft' or 'bottomright'
"   a:size => the size of the window. For horizontal ones it refers to the
"   height, for the vertical ones to the width
"   a:multi_tab => wherever or not the window may have different contents
"   accross vim tabs
function! voraxlib#widget#window#New(name, orientation, anchor, size, multi_tab)
  " check the name is valid
  if a:name !~? '^[a-z_]\+$'
  	throw 'Invalid window name'
  endif
  " create a new object
  let window = deepcopy(s:window)
  let window.name = a:name
  " check and init the split type
  if a:orientation == 'h'
    let window.orientation = ''
  elseif a:orientation == 'v'
    let window.orientation = 'vertical'
  else
    throw "Invalid orientation"
  endif
  if a:anchor == 'topleft' || a:anchor == 'botright'
    let window.anchor = a:anchor
  else
    throw "Invalid anchor"
  endif
  let window.size = a:size
  let window.multi_tab = a:multi_tab
  return window
endfunction

" This function is intended to be overridden. It is called
" after the window is created and should contain setlocal
" settings, syntax, mappings etc.
function! s:window.Configure() dict
endfunction

" This function is intended to be overridden. It is called
" in order to add content to the window.
function! s:window.Render() dict
endfunction

" Open the window.
function! s:window.Open() dict
  if !self.IsOpen()
    " okey, the window is not open
    let split_action = ''
    let buffer_action = ''
    if !exists('t:' . self.name)
      " the window was never open within the current tab
      if self.multi_tab
        " if the window is multitab increment its instance number
        let self.instance_no += 1
      endif
      " init a tab variable which points to the buffer name hold by this
      " window
      exe 'let t:' . self.name . ' = ' . "'" . self.name . (self.multi_tab ? self.instance_no : "") . "'"
      let split_action = 'new'     " the split with a 'new' clause
      let buffer_action = 'edit'   " asume the buffer does not exist
    else
      let split_action = 'split'   " split with a 'split' clause
      let buffer_action = 'buffer' " asume the buffer exist
    endif
    " make the split with the clauses computed before
    exec self.anchor . ' ' . self.orientation . ' ' . self.size . ' ' . split_action
    let must_render = 0
    " check if the buffer behind the window exist
    if bufnr(eval('t:' .self.name)) == -1
      " the buffer does not exist therefore we have to force a render after
      " the buffer will be actually created
      let must_render = 1
    endif
    " create/activate the buffer behind the window
    exec 'silent! ' . buffer_action . " " . eval('t:' . self.name)
    " configure window
    call self.Configure()
    " if the buffer didn't exist before then a Render() call is made
    if must_render
    	call self.Render()
    endif
else
  	" the window is already opened
  	" just set focus on this window
    call self.Focus()
  endif
endfunction

" Is the window focused?
function! s:window.HasFocus() dict
  if exists('t:'.self.name)
    return bufwinnr(eval("t:" . self.name)) == bufwinnr('%')
  else
  	" the window has never been openned
  	return 0
  endif
endfunction

" Focus the window
function! s:window.Focus() dict
  if self.IsOpen()
    exe self.WinNum() . 'wincmd w'
  else
  	call self.Open()
  endif
endfunction

" Close the window
function! s:window.Close() dict
  if self.IsOpen()
    call self.Focus()
    close!
  endif
endfunction

" Toggle the window
function! s:window.Toggle() dict
  if self.IsOpen()
  	call self.Close()
  else
  	call self.Open()
  end
endfunction

" Is the window open/visible?
function! s:window.IsOpen() dict
  return self.WinNum() != -1
endfunction

" Get the window number.
function! s:window.WinNum() dict
    if exists("t:" . self.name)
        return bufwinnr(eval("t:" . self.name))
    else
        return -1
    endif
endfunction

" Lock the content of the window
function! s:window.LockBuffer() dict
  if self.IsOpen()
    call self.Focus()
    setlocal nomodifiable nomodified
  endif
endfunction

" Unlock the content of the window
function! s:window.UnlockBuffer() dict
  if self.IsOpen()
    call self.Focus()
    setlocal modifiable
  endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

