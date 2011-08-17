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
  if exists('g:acp_behavior')
    let g:acp_behavior['sql'] = [ {'command' : "\<C-x>\<C-o>", 'meets' : 'voraxlib#omni#Meets', 'repeat' : 0, 'onPopupClose' : 'voraxlib#omni#OnPopupClose'} ]
  endif

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

  " explain plan mappings
  let mapdesc = maparg(g:vorax_explain_key, 'n', 0, 1)
  if g:vorax_explain_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer> " . g:vorax_explain_key . " <Plug>VoraxExplain"
  endif
  let mapdesc = maparg(g:vorax_explain_only_key, 'n', 0, 1)
  if g:vorax_explain_only_key!= '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer>" . g:vorax_explain_only_key . " <Plug>VoraxExplainOnly"
  endif
  let mapdesc = maparg(g:vorax_explain_key, 'v', 0, 1)
  if g:vorax_explain_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "xmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer>" . g:vorax_explain_key . " :call vorax#Explain(voraxlib#utils#SelectedBlock(), 0)<cr>"
  endif
  let mapdesc = maparg(g:vorax_explain_only_key, 'v', 0, 1)
  if g:vorax_explain_only_key != '' 
        \ && ((has_key(mapdesc, 'buffer') && !mapdesc['buffer']) || empty(mapdesc))
    exe "xmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . " <buffer>" . g:vorax_explain_only_key . " :call vorax#Explain(voraxlib#utils#SelectedBlock(), 1)<cr>"
  endif


  " create common mappings
  call vorax#CreateCommonKeyMappings()

endif

