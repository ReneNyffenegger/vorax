" Various utilities for VoraX GUI testing.
if !exists('g:vorax_test_gui_servername') | let g:vorax_test_gui_servername = 'VORAX_TEST_SERVER' | endif
if !exists('g:vorax_test_gui_timeout') | let g:vorax_test_gui_timeout = 3000 | endif
if !exists('g:vorax_test_gui_vim_exe') | let g:vorax_test_gui_vim_exe = 'gvim' | endif

" Initialize the vim server for GUI testing.
function! VoraxCreateGuiBuddy()
  for vim_server in split(serverlist(), "\n")
    if vim_server == g:vorax_test_gui_servername
      call s:DestroyVimServer()
      break
    end
  endfor
  " starts a new vim as a server
  silent exe "!" . g:vorax_test_gui_vim_exe . " --servername " . g:vorax_test_gui_servername
  " wait max 3s to initialize
  for i in range(30)
    try
      call remote_expr(g:vorax_test_gui_servername, "1+1")
    catch /.*/
      sleep 100m
    endtry
  endfor
  call foreground()
endfunction

" Destroy the Vim server.
function! VoraxKillGuiBuddy()
  let pid = str2nr(remote_expr(g:vorax_test_gui_servername, 'getpid()'))
  ruby Process.kill(9, VIM::evaluate('pid'))
endfunction

" Evaluates a boolean expression on the remote server taking into account the
" defined timeout. If within the given timeout the expression doesn't evaluate
" to TRUE then this function returns FALSE.
function! IsGuiBuddyOk(expr)
  for i in range(g:vorax_test_gui_timeout / 100)
    if remote_expr(g:vorax_test_gui_servername, a:expr)
      return 1
    else
    	sleep 100m
    endif
  endfor
  return 0
endfunction

