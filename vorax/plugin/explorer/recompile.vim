" Description: RECOMPILE vorax explorer plugin.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_vorax_plugin_explorer_recompile") 
 finish
endif

let g:_loaded_vorax_plugin_explorer_recompile = 1
let s:cpo_save = &cpo
set cpo&vim

TLet g:vorax_explorer_plugin_recompile_key = 're'

" Create the plugin skeleton
let s:plugin = g:vorax_explorer.GetPluginSkeleton()
let s:plugin.label = 'Recompile'
let s:plugin.description = 'Recompile the database object.'
let s:plugin.shortcut = g:vorax_explorer_plugin_recompile_key

" the functions which tells for what nodes the plugin should be available.
function! s:plugin.IsActive(path)
  let info = g:vorax_explorer.DescribePath(a:path)
  " Only for packages and types please
  if info.type == 'PACKAGE' || info.type == 'TYPE' || info.type == 'VIEW'
        \ || info.type == 'PROCEDURE' || info.type == 'FUNCTION' || info.type == 'TRIGGER'
    return 1
  else
  	return 0
  endif
endfunction

" What to do when the plugin is invoked
function! s:plugin.Callback()
  let crr_node = g:vorax_explorer.GetCurrentNode()
  let info = g:vorax_explorer.DescribePath(crr_node)
  if self.IsActive(crr_node)
    let sqlplus = vorax#GetSqlplusHandler()
    let output_window = vorax#GetOutputWindowHandler()
    let cmd = 'ALTER ' . info.type . ' "' . info.owner . '"."' . info.object . '" COMPILE;' 
    let output = sqlplus.Exec(cmd, {'sqlplus_options' : sqlplus.GetSafeOptions()})
    " sqlplus show errors command doesn't work correctly for OWNER. prefixed
    " objects therefore just use the ALL_ERRORS table.
    let cmd = "select line || '/' ||  position \"LINE/COL\", text ERROR from all_errors where owner = '" . info.owner . "' and name='". info.object . "';\n"
    let output .= sqlplus.Exec(cmd, {'sqlplus_options' : extend(sqlplus.GetSafeOptions(), [{'option' : 'feedback', 'value' : 'off'}])})
    call output_window.AppendText(output)
    if output =~ 'LINE/COL\s\+ERROR'
      " this means we have compilation errors
      if crr_node !~ '!$' 
        " refresh only if the object was shown as valid before in the db explorer
        call g:vorax_explorer.RefreshNode(crr_node . '!')
      endif
    else
      " no compilation errors
      if crr_node =~ '!$' 
        " refresh only if the object was shown as invalid before in the db explorer
        call g:vorax_explorer.RefreshNode(substitute(crr_node, '!$', '', ''))
      endif
    endif
    call g:vorax_explorer.window.Focus()
  endif
endfunction

call g:vorax_explorer.RegisterPlugin(expand("<sfile>:t:r"), s:plugin)

let &cpo=s:cpo_save
unlet s:cpo_save


