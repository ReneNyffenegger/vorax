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
    " Choose a path separator so that no clashes will occur
    let s:explorer.path_separator = '"'
    " Add additional methods to the s:profiles object.
    call s:ExtendExplorer()
    let s:initialized = 1
  endif
  return s:explorer
endfunction"}}}

" Add additional methods.
function! s:ExtendExplorer()"{{{

  " Get children profiles for the provided path.
  function! s:explorer.GetSubNodes(path)"{{{
    if a:path == self.root
      return s:GetExplorerCategories(1)
    elseif s:IsUsersCategoryNode(a:path)
      return s:GetUsers()
    elseif s:IsAnUserNode(a:path)
      return s:GetExplorerCategories(0)
    elseif s:IsObjectsCategoryNode(a:path)
      return s:GetObjects(a:path)
    elseif 
    endif
  endfunction}}}
  
  " Initialize the tree window.
  function! s:explorer.window.Configure()"{{{
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
  function! s:explorer.IsLeaf(path)"{{{
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

  " Describes the provided path. The following attributes are returned via a
  " dictionary:
  " {'owner'  : '<owner of the object> as an oracle expression: user for
  "              current user or 'owner' (as literal) for the owner under the 
  "              [Users] category', 
  "  'type'   : '<the type of the object> as expected by Oracle: TABLE, TYPE
  "              etc.', 
  "  'object'  : '<the name of the object>'
  "  }
  function! s:explorer.DescribePath(path)"{{{
    let desc = {'owner' : '', 'type' : '', 'object' : ''}
    let parts = split(a:path, voraxlib#utils#LiteralRegexp(self.path_separator))
    let index = 1
    let desc.owner = 'user'
    if parts[1] == '[Users]'
      let index = 3
      if exists('parts[2]')
        let desc.owner = "'" . substitute(parts[2], '\v(^\[)|(\]$)', '', 'g') . "'"
      endif
    endif
    if len(parts) > index
      " fill the desc dictionary only if the path is long enough
      let desc.type = s:ToOracleType(parts[index])
      let desc.object = substitute(get(parts, index + 1, ''),  '\v(^\[)|(\]$)', '', 'g')
      if (desc.type == 'PACKAGE' || desc.type == 'TYPE') &&
            \ (parts[-1] == 'Body' || parts[-1] == 'Spec')
        let desc.type .= '_' . toupper(parts[-1])
      endif
    end
    return desc
  endfunction"}}}

endfunction"}}}


" === PRIVATE FUNCTIONS ==="{{{

" Get the list of users.
function! s:GetUsers()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let output = sqlplus.Query('select username from all_users order by 1;',
        \ {'executing_msg' : 'Get users...',
        \  'throbber' : vorax#GetDefaultThrobber(),
        \  'done_msg' : 'Done.'})
  if empty(output.errors)
    return map(copy(output.resultset), '"[".v:val["USERNAME"]."]"')
  else
  	voraxlib#utils#Warn("WTF? What's with this error?\n" . join(output.errors, "\n"))
  	return []
  endif
endfunction"}}}

" Get the corresponding tables for the provided node path.
function! s:GetObjects(path)
  let info = s:explorer.DescribePath(a:path)
  if info.owner != '' && info.type != ''
    let sqlplus = vorax#GetSqlplusHandler()
    let output = sqlplus.Query('select object_name from all_objects ' . 
          \'where owner=' . info.owner . ' and object_type=''' . info.type . ''' order by 1;',
          \ {'executing_msg' : 'Load objects...',
          \  'throbber' : vorax#GetDefaultThrobber(),
          \  'done_msg' : 'Done.'})
    if empty(output.errors)
      return map(copy(output.resultset), 'v:val["OBJECT_NAME"]')
    else
      voraxlib#utils#Warn("WTF? What's with this error?\n" . join(output.errors, "\n"))
    endif
  endif
  return []
endfunction

" Whenever or not the provided path points to the [Users] node
function! s:IsUsersCategoryNode(path)"{{{
  return a:path == s:explorer.root . s:explorer.path_separator . '[Users]'
endfunction"}}}

" Whenever the provided path points out to a specific user
function! s:IsAnUserNode(path)
  let parts  = split(a:path, voraxlib#utils#LiteralRegexp(s:explorer.path_separator)) 
  return len(parts) == 3 && parts[1] == '[Users]'
endfunction

" Is it the [Tables] node?
function! s:IsObjectsCategoryNode(path)
  let parts  = split(a:path, voraxlib#utils#LiteralRegexp(s:explorer.path_separator)) 
  " Could be: root > [Tables] or
  "           root > [Users] > [WhateverUser] > [Tables]
  return (len(parts) == 2 || len(parts) == 4)
endfunction


" Convert a generic explorer category to an Oracle type.
function! s:ToOracleType(vorax_category)"{{{
  return toupper(substitute(a:vorax_category, '\v(^\[)|(s\]$)', '', 'g'))
endfunction"}}}

" Get the generic explorer categories.
function! s:GetExplorerCategories(include_users)"{{{
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
endfunction"}}}

" Click for the current object. This is a dummy function which is called from
" the tree key mapping.
function! s:Click()"{{{
  call s:explorer.ClickNode(s:explorer.GetCurrentNode())
endfunction"}}}

"}}}
