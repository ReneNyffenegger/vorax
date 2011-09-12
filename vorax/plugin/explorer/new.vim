" Description: Create a new object from the explorer.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_vorax_plugin_explorer_new") 
  finish
endif

let g:_loaded_vorax_plugin_explorer_new = 1
let s:cpo_save = &cpo
set cpo&vim

if !exists('g:vorax_explorer_plugin_new_key')
	let g:vorax_explorer_plugin_new_key = 'cr'
endif

" Create the plugin skeleton
let s:plugin = g:vorax_explorer.GetPluginSkeleton()
let s:plugin.label = 'Create'
let s:plugin.shortcut = g:vorax_explorer_plugin_new_key

" the functions which tells for what nodes the plugin should be available.
function! s:plugin.IsActive(path)
  if !exists( "g:__XPTEMPLATE_VIM__" )
    " cannot work without xptemplate plugin
    return 0
  endif
  let s:info = g:vorax_explorer.DescribePath(a:path)
  " Only for some categories
  if (s:info.type == 'PACKAGE' 
        \ || s:info.type == 'TYPE' 
        \ || s:info.type == 'PROCEDURE'
        \ || s:info.type == 'FUNCTION'
        \ || s:info.type == 'TRIGGER') && empty(s:info.object)
    let s:plugin.description = 'Create a new ' . (s:info.type) . '.'
    return 1
  else
  	return 0
  endif
endfunction

" What to do when the plugin is invoked
function! s:plugin.Callback()
  let crr_node = g:vorax_explorer.GetCurrentNode()
  if self.IsActive(crr_node)
    let object_name = input("Enter the name for this new " . s:info.type . " object: ")
    if !empty(object_name)
      let file_name = voraxlib#utils#GetFileName(object_name, s:info.type)
      let bufnr = bufnr(file_name)
      silent! call voraxlib#utils#FocusCandidateWindow()
      if bufnr == -1 || empty(getbufline(bufnr, 0, '$'))
        " create a new buffer
        silent! exe 'edit ' . file_name
        " clear content if the file exists
        normal gg"_dG
        let b:vorax_module = {'owner' : s:info.owner, 'type' : s:info.type, 'object' : toupper(object_name)}
        starti
        call XPTtgr("_new_" . tolower(s:info.type))
      else
        " just focus that buffer
        exe 'buffer ' . bufnr
      endif
    endif
  endif
endfunction

call g:vorax_explorer.RegisterPlugin(expand("<sfile>:t:r"), s:plugin)

let &cpo=s:cpo_save
unlet s:cpo_save

