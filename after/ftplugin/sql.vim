" Description: Overwrite settings for Oracle sql file type
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if voraxlib#utils#IsSqlOracleBuffer()
  " apply these customizations only for SQL Oracle. 

  " consider $# as word characters
  setlocal isk+=$
  setlocal isk+=#

  " code completion
  setlocal omnifunc=voraxlib#omni#Complete
  let g:acp_behavior['sql'] = [ {'command' : "\<C-x>\<C-o>", 'meets' : 'voraxlib#omni#Meets', 'repeat' : 0} ]

  " init sql buffer mappings
  " Mappings for exec statement"{{{
  if g:vorax_exec_key != '' 
        \ && !hasmapto('<Plug>VoraxExecCurrent') 
        \ && maparg(g:vorax_exec_key, 'n') == ""
    exe "nmap <unique> " . g:vorax_exec_key . " <Plug>VoraxExecCurrent"
  endif
  if g:vorax_exec_key != '' 
        \ && !hasmapto('<Plug>VoraxExecSelection') 
        \ && maparg(g:vorax_exec_key, 'v') == ""
    exe "xmap <unique> " . g:vorax_exec_key . " <Plug>VoraxExecSelection"
  endif"}}}

  " create common mappings
  call vorax#CreateCommonKeyMappings()

endif

