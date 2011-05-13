" This is the test suite (regresion) for VoraX.
" It runs all tests and displays the overall testing statistics. The [vimunit]
" plugin must be installed: https://github.com/dsummersl/vimunit
"
" By convention:
"   1. every unit test script resides under tests/vorax/ut/*
"   2. the main function which invokes the test cases should be named
"   following a well known pattern: TestVorax[your suffix].
"
" Some unit tests need to connect to an Oracle database. The connect string
" used by those unit tests is provided by g:vorax_test_constr global variable.
" You can initialize this variable in your .vimrc file or you may change and
" uncomment the below line accordingly:
"
" let g:vorax_test_constr = 'vorax/vorax@your_db'
"
" In order to setup an oracle vorax test user you have to run the following
" script: tests/vorax/sql/setup_vorax_test_user.sql.
"
" Some GUI features need to be tested with a remote vim in place. This means
" that a new VIM process will be created by this test suite. The GUI testing
" part is controlled by the following global variables:
"
" g:vorax_test_gui: enable or disable GUI testing (by default 1)
" g:vorax_test_gui_servername: the name of the vim server
" g:vorax_test_gui_vim_exe: the vim executable to use when launching the
" remote vim server.
"
" To run the regression test use:
"   :so %
" and look at the displayed statistics.

if !exists('g:vorax_test_gui') | let g:vorax_test_gui = 1 | endif
if !exists('g:vorax_test_gui_servername') | let g:vorax_test_gui_servername = 'VORAX_TEST_SERVER' | endif
if !exists('g:vorax_test_gui_vim_exe') | let g:vorax_test_gui_vim_exe = 'gvim' | endif

" Create the suite.
function! TestSuiteForVorax()
  " don't mess up the current vorax home dir. Create a new vorax home dir just
  " for tests.
  let save_vorax_home_dir = g:vorax_home_dir
  let g:vorax_home_dir = fnamemodify(expand('$HOME'). '/vorax_test', ':8')
  if !isdirectory(g:vorax_home_dir)
    call mkdir(g:vorax_home_dir, '')
  endif
  " cleanup unit tests
  call s:VoraxUnitTestsCleanup()
  " load unit tests
  runtime! tests/vorax/ut/**/*.vim
  " every Vorax unit test starts with TestVorax*
  " loop through all the functions which match TestVorax*
  for func_name in s:GetVoraxUnitTests()
    echo '   exec: ' . func_name
    exe 'call ' . func_name
  endfor
  " restore the old value
  let g:vorax_home_dir = save_vorax_home_dir
endfunction

" Get all vorax unit test functions.
function! s:GetVoraxUnitTests()
  let func_list = ''
  redir => func_list
  silent fu /^TestVorax
  redir END
  return map(split(func_list, "\n"), "substitute(v:val, '^function ', '', '')")
endfunction

" Remove all function references to TestVorax* unit tests.
function! s:VoraxUnitTestsCleanup()
  for func_name in s:GetVoraxUnitTests()
    exe 'delfunction ' . substitute(func_name, '()$', '', '')
  endfor
endfunction

" Initialize the vim server for GUI testing.
function! s:InitVimServer()
  for vim_server in split(serverlist(), "\n")
    if vim_server == g:vorax_test_gui_servername
      let pid = str2nr(remote_expr(g:vorax_test_gui_servername, 'getpid()'))
      ruby Process.kill(9, VIM::evaluate('pid'))
    end
  endfor
  " starts a new vim as a server
  silent exe "!" . g:vorax_test_gui_vim_exe . " --servername " . g:vorax_test_gui_servername
endfunction

" Initialize the remote vim server
if g:vorax_test_gui | call s:InitVimServer() | endif

" Run suite.
call VURunnerRunTest('TestSuiteForVorax')
