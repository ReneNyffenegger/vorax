" This is the regression test for VoraX. It relies on UT vim plugin. You may
" find additional details about it here:
"
"   http://code.google.com/p/lh-vim/wiki/UT
"
" In order to run this regression:
"   1. change directory to ~/.vim (or vorax base dir in case of pathogen)
"   2. :so tests/vorax/_REGRESION_.vim
"   3. inspect the quick fix window for any assert failures

call lh#UT#run("", 'tests/vorax/sqlplus.vim')
call lh#UT#run("!", 'tests/vorax/widget/throbber.vim')
call lh#UT#run("!", 'tests/vorax/widget/window.vim')
call lh#UT#run("!", 'tests/vorax/parser/constring.vim')
