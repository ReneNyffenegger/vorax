" Description: Overwrite settings for Oracle sql file type
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if voraxlib#utils#IsSqlOracleBuffer()
  " apply these customizations only for SQL Oracle. 

  " consider $# as word characters
  setlocal isk+=$
  setlocal isk+=#

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

  " matchit functionality 
  " Some standard expressions for use with the matchit strings
  let s:notend = '\%(\<end\s\+\)\@<!'
  let s:when_no_matched_or_others = '\%(\<when\>\%(\s\+\%(\%(\<not\>\s\+\)\?<matched\>\)\|\<others\>\)\@!\)'
  let s:or_replace = '\%(or\s\+replace\s\+\)\?'

  " Define patterns for the matchit macro
  let b:match_words =
                  \ '\(^\s*\)\@<=\(\<\%(for\|while\|loop\)\>.*\):'.
                  \ '\%(\<exit\>\|\<leave\>\|\<break\>\|\<continue\>\):'.
                  \ '\%(\<end\s\+\<loop\>\),' .
                  \ s:notend . '\<if\>:'.
                  \ '\<elsif\>\|\<elseif\>\|\<else\>:'.
                  \ '\<end\s\+if\>,'.
                  \ '\<begin\>:'.
                  \ '\%(\<end\>\s*\(\(\<if\>\|\<loop\>\)\@!.\)*$\),' 

endif

