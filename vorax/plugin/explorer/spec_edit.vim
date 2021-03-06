" Description: Edit SPEC vorax explorer plugin.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_vorax_plugin_explorer_spec_edit") 
 finish
endif

let g:_loaded_vorax_plugin_explorer_spec_edit = 1
let s:cpo_save = &cpo
set cpo&vim

if !exists('g:vorax_explorer_plugin_spec_edit_key')
	let g:vorax_explorer_plugin_spec_edit_key = 'sp'
endif

" Create the plugin skeleton
let s:plugin = g:vorax_explorer.GetPluginSkeleton()
let s:plugin.label = 'Edit SPEC'
let s:plugin.description = 'Open just the SPEC of the PL/SQL module.'
let s:plugin.shortcut = g:vorax_explorer_plugin_spec_edit_key

" the functions which tells for what nodes the plugin should be available.
function! s:plugin.IsActive(path)
  let info = g:vorax_explorer.DescribePath(a:path)
  " Only for packages and types please
  if (info.type == 'PACKAGE' || info.type == 'TYPE') && !empty(info.object)
    return 1
  else
  	return 0
  endif
endfunction

" What to do when the plugin is invoked
function! s:plugin.Callback()
  let info = g:vorax_explorer.DescribePath(g:vorax_explorer.GetCurrentNode())
  if !empty(s:info.object)
    if info.type == 'PACKAGE'
      let type = 'PACKAGE_SPEC'
    elseif info.type == 'TYPE'
      let type = 'TYPE_SPEC'
    endif
  endif
  if exists('type')
    call vorax#LoadDbObject(info.owner, info.object, type)
  endif
endfunction

call g:vorax_explorer.RegisterPlugin(expand("<sfile>:t:r"), s:plugin)

let &cpo=s:cpo_save
unlet s:cpo_save
