" Description: Implements the VoraX database explorer panel/window. This is
" a window with a tree containing database objects.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_panel_explorer") 
 finish
endif

let g:_loaded_voraxlib_panel_explorer = 1
let s:cpo_save = &cpo
set cpo&vim

if exists('s:initialized') | unlet s:initialized | endif

" Initialize logger
let s:log = voraxlib#logger#New(expand('<sfile>:t'))

" The profiles window instance.
let s:explorer = {}

" The generic explorer plugin skeleton. {{{
let s:plugin_skeleton = {'label' : '', 'shortcut' : '', 'description' : ''}

" Is the plugin active for the provided node?
function! s:plugin_skeleton.IsActive(path)
endfunction

" What to do when the plugin is invoked.
function! s:plugin_skeleton.Callback()
endfunction

" Configure the plugin (e.g. keymaps)
function! s:plugin_skeleton.Configure()
endfunction

"}}}

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
    let s:explorer['plugins'] = {}
    let s:explorer['plugins_configured'] = 0
    let s:explorer['must_refresh'] = 0
    " Add additional methods to the s:profiles object.
    call s:ExtendExplorer()
    " Register plugins
    let g:vorax_explorer = s:explorer
    runtime! vorax/plugin/explorer/**/*.vim
    let s:initialized = 1
  endif
  " this global variable may be used by explorer plugins
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
    "setlocal winfixwidth
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nospell
    setlocal nonu
    setlocal cursorline
    setlocal noswapfile
    setlocal hid

    " set colors
    syn match Directory  '^\s*\(+\|-\).\+'
    syn match Error  '.*!$'
    hi link Directory  Comment

    " set key mappings
    noremap <silent> <buffer> o :call <SID>Click()<CR>
    noremap <silent> <buffer> <CR> :call <SID>Click()<CR>
    exe 'noremap <silent> <buffer> ' . g:vorax_explorer_window_refresh_key . ' :call <SID>Refresh()<CR>'
    exe 'noremap <silent> <buffer> ' . g:vorax_explorer_window_menu_key . ' :call <SID>Menu()<CR>'

    " configure plugins
    call s:explorer._ConfigureMappingsForPlugins()

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

  " What to do when a profile node is clicked.
  function! s:explorer.OnLeafClick(path)"{{{
    let info = self.DescribePath(a:path)
    call vorax#LoadDbObject(info.owner, info.object, info.type)
  endfunction"}}}

  " Get the skeleton for a new explorer plugin.
  function! s:explorer.GetPluginSkeleton()"{{{
    return copy(s:plugin_skeleton)
  endfunction"}}}

  " Register a new plugin.
  function! s:explorer.RegisterPlugin(id, plugin)"{{{
    if s:log.isDebugEnabled() | call s:log.debug('Register explorer plugin: ID=' . string(a:id) . ' PLUGIN=' . string(a:plugin)) | endif
    let self.plugins[a:id] = a:plugin
  endfunction"}}}

  " Refresh the whole explorer.
  function! s:explorer.Refresh()"{{{
    let self.window.Focus()
    let state = winsaveview()
    let root = vorax#GetSqlplusHandler().GetConnectedTo()
    call self.SetRoot(root)
    let self.must_refresh = 0
    call winrestview(state)
  endfunction"}}}

  " Toggle the profiles window.
  function! s:explorer.Toggle() "{{{
    if self.root == ''
      call self.Refresh()
    else
      call self.window.Toggle()
    	if self.must_refresh && self.window.IsOpen()
        call self.Refresh()
      endif
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
    if s:log.isTraceEnabled() | call s:log.trace('BEGIN s:explorer.DescribePath(' . string(a:path) . ')') | endif
    let desc = {'owner' : '', 'type' : '', 'object' : ''}
    let parts = split(a:path, voraxlib#utils#LiteralRegexp(self.path_separator))
    let index = 1
    if parts[1] == '[Users]'
      let index = 3
      if exists('parts[2]')
        let desc.owner = substitute(parts[2], '\v(^\[)|(\]$)', '', 'g')
      endif
    endif
    if desc.owner == ''
      let result = vorax#GetSqlplusHandler().Query('select sys_context(''USERENV'', ''SESSION_USER'') crr_user from dual;')
      if s:log.isDebugEnabled() | call s:log.debug('current user: ' . string(result)) | endif
      if empty(result.errors)
        let desc.owner = get(get(result.resultset, 0), 'CRR_USER')
      else
        if s:log.isErrorEnabled() | call s:log.error(string(result.errors)) | endif
        call voraxlib#utils#Warn("WTF? What's with this error?\n" . join(result.errors, "\n"))
      endif
    endif
    if len(parts) > index
      " fill the desc dictionary only if the path is long enough
      let desc.type = s:ToOracleType(parts[index])
      let desc.object = substitute(get(parts, index + 1, ''),  '\v(^\[)|(\]$|(!$))', '', 'g')
    end
    if s:log.isTraceEnabled() | call s:log.trace('END s:explorer.DescribePath => ' . string(desc)) | endif
    return desc
  endfunction"}}}

  " Internal function for configuring mappings for the plugins.
  function! s:explorer._ConfigureMappingsForPlugins()
    if !s:explorer.plugins_configured
      if s:log.isDebugEnabled() | call s:log.debug('Configure explorer plugins') | endif
      for id in keys(s:explorer.plugins)
        let plugin = s:explorer.plugins[id]
        if plugin.shortcut != ''
          let command = 'noremap <silent> <buffer> ' . plugin.shortcut . ' :call g:vorax_explorer.plugins["' . escape(id, '/"') . '"].Callback()<CR>'
          if s:log.isDebugEnabled() | call s:log.debug(command) | endif
          exe command
        endif
      endfor
      let s:explorer.plugins_configured = 1
    endif
  endfunction

endfunction"}}}

" === PRIVATE FUNCTIONS ==="{{{

" Get the list of users.
function! s:GetUsers()"{{{
  let sqlplus = vorax#GetSqlplusHandler()
  let output = sqlplus.Query('select username from all_users where username != sys_context(''USERENV'', ''SESSION_USER'') order by 1;',
        \ {'executing_msg' : 'Get users...',
        \  'throbber' : vorax#GetDefaultThrobber(),
        \  'done_msg' : 'Done.'})
  if empty(output.errors)
    return map(copy(output.resultset), '"[".v:val["USERNAME"]."]"')
  else
  	call voraxlib#utils#Warn("WTF? What's with this error?\n" . join(output.errors, "\n"))
  	return []
  endif
endfunction"}}}

" Get the corresponding tables for the provided node path.
function! s:GetObjects(path)"{{{
  let info = s:explorer.DescribePath(a:path)
  if info.owner != '' && info.type != ''
    let sqlplus = vorax#GetSqlplusHandler()
    let output = sqlplus.Query('select object_name || decode(status, ''INVALID'', ''!'', '''') object_name from all_objects ' . 
          \'where owner=''' . info.owner . ''' and object_type=replace(''' . info.type . ''', ''_'', '' '') order by 1;',
          \ {'executing_msg' : 'Load objects...',
          \  'throbber' : vorax#GetDefaultThrobber(),
          \  'done_msg' : 'Done.'})
    if empty(output.errors)
      return map(copy(output.resultset), 'v:val["OBJECT_NAME"]')
    else
      call voraxlib#utils#Warn("WTF? What's with this error?\n" . join(output.errors, "\n"))
    endif
  endif
  return []
endfunction"}}}

" Whenever or not the provided path points to the [Users] node
function! s:IsUsersCategoryNode(path)"{{{
  return a:path == s:explorer.root . s:explorer.path_separator . '[Users]'
endfunction"}}}

" Whenever the provided path points out to a specific user
function! s:IsAnUserNode(path)"{{{
  let parts  = split(a:path, voraxlib#utils#LiteralRegexp(s:explorer.path_separator)) 
  return len(parts) == 3 && parts[1] == '[Users]'
endfunction"}}}

" Is it a [Category] node?
function! s:IsObjectsCategoryNode(path)"{{{
  let parts  = split(a:path, voraxlib#utils#LiteralRegexp(s:explorer.path_separator)) 
  " Could be: root > [Tables] or
  "           root > [Users] > [WhateverUser] > [Tables]
  return (len(parts) == 2 || len(parts) == 4)
endfunction"}}}

" Convert a generic explorer category to an Oracle type.
function! s:ToOracleType(vorax_category)"{{{
  return substitute(toupper(substitute(a:vorax_category, '\v(^\[)|(s\]$)', '', 'g')), ' ', '_', 'g')
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
        \  "[Materialized Views]"]
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

" Refresh the current node.
function! s:Refresh()"{{{
  call s:explorer.RefreshNode(s:explorer.GetCurrentNode())
endfunction"}}}

" Display the menu for the current node.
function! s:Menu()"{{{
  let node = s:explorer.GetCurrentNode()
  let state = { 
              \ 'type': 'si',
              \ 'query': 'Select the action you want to perform.',
              \ 'pick_last_item': 0,
              \ 'allow_suspend' : 0,
              \ 'numeric_chars': extend(g:tlib_numeric_chars, {48:48, 49:48, 50:48, 51:48, 52:48, 53:48, 54:48, 55:48, 56:48, 57:48}),
              \ 'key_handlers': [
                  \ {'key': 9, 'agent': 'tlib#agent#Down', 'key_name': '<Tab>', 'help': 'Select the next item.'},
                  \ {'key': "\<S-Tab>", 'agent': 'tlib#agent#Up', 'key_name': '<S-Tab>', 'help': 'Select the previous item.'},
              \ ],
              \ }
  let state.base = []
  let active_plugins = []
  for id in keys(s:explorer.plugins)
    let plugin = s:explorer.plugins[id]
    if plugin.IsActive(node)
      call add(state.base, plugin.label . ' [' . plugin.shortcut . '] : ' . plugin.description)
      call add(active_plugins, plugin)
    endif
  endfor
  let choice = tlib#input#ListD(state)
  if choice
    call active_plugins[choice-1].Callback()
  endif
endfunction"}}}

"}}}
