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
" To run the regression test use:
"   :so %
" and look at the displayed statistics.

" Create the suite.
function! TestSuiteForVorax()
  " don't mess up the current vorax home dir. Create a new vorax home dir just
  " for tests.
  let save_vorax_home_dir = g:vorax_home_dir
  let g:vorax_home_dir = substitute(expand('$HOME') . '/.vorax_test', '\\\\\|\\', '/', 'g')
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

" Run suite.
call VURunnerRunTest('TestSuiteForVorax')
