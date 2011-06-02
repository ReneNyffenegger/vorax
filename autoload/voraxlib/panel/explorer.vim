" Description: Implements the VoraX database explorer panel/window. This is
" a window with a tree with database objects.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_panel_explorer") 
 finish
endif

let g:_loaded_voraxlib_panel_explorer = 1
let s:cpo_save = &cpo
set cpo&vim

if exists('s:initialized') | unlet s:initialized | endif

" The profiles window instance.
let s:explorer = {}

" Creates a new connection profiles window. Only one such window
" is allowed in a VoraX instance. 
function! voraxlib#panel#explorer#New()"{{{
  if !exists('s:initialized')
    " Create the container window for the profiles tree.
    let win = voraxlib#widget#window#New('__VoraxExplorer__', 
          \ g:vorax_explorer_window_orientation,
          \ g:vorax_explorer_window_anchor, 
          \ g:vorax_explorer_window_size,
          \ 0)
    " No profile tree has been initialized. Create it now.
    let s:explorer = voraxlib#widget#tree#New(win) 
    " Add additional methods to the s:profiles object.
    call s:ExtendExplorer()
    let s:initialized = 1
  endif
  return s:explorer
endfunction"}}}

" Add additional methods.
function! s:ExtendExplorer()"{{{

  " Get children profiles for the provided path.
  function! s:explorer.GetSubNodes(path) dict"{{{
    if a:path == self.root
      return s:GetExplorerCategories(1)
    endif
  endfunction}}}
  
  " Initialize the tree window.
  function! s:explorer.window.Configure() dict"{{{
    " set options
    setlocal foldcolumn=0
    setlocal winfixwidth
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nospell
    setlocal nonu
    setlocal cursorline
    setlocal noswapfile
    setlocal hid

    " set colors
    syn match Directory  '^\s*\(+\|-\).\+'
    hi link Directory  Comment

    " set key mappings
    noremap <silent> <buffer> o :call <SID>Click()<CR>
    noremap <silent> <buffer> <CR> :call <SID>Click()<CR>
  endfunction"}}}
  
  " Whenever or not the node is a leaf one.
  function! s:explorer.IsLeaf(path) dict"{{{
    if self.IsCategory(a:path)
      " if ends with a ']' then it's a category.
      return 0
    else
      return 1
    endif
  endfunction"}}}

  " Toggle the profiles window.
  function! s:explorer.Toggle() "{{{
    if self.root == ''
      let root = vorax#GetSqlplusHandler().GetConnectedTo()
      call self.SetRoot(root)
    else
    	call self.window.Toggle()
    endif
  endfunction"}}}

  " Whenever or not the provided node refers to a category.
  function! s:explorer.IsCategory(node)"{{{
   return a:node =~ ']$'
  endfunction"}}}

endfunction"}}}


" === PRIVATE FUNCTIONS ==="{{{

function! s:GetExplorerCategories(include_users)
  let categories = ["[Tables]",
        \  "[Views]",
        \  "[Procedures]",
        \  "[Functions]",
        \  "[Packages]",
        \  "[Synonyms]",
        \  "[Types]",
        \  "[Triggers]",
        \  "[Sequences]",
        \  "[MViews]"]
  if a:include_users
    call add(categories, "[Users]")
  endif
  return categories
endfunction

"}}}
