" VoraX:      an oracle IDE under vim
" Author:     Alexandru Tică
" Date:	      15/04/10 14:08:20  
" Copyright:  Copyright (C) 2010 Alexandru Tică
"             Apache License, Version 2.0
"             http://www.apache.org/licenses/LICENSE-2.0.html

if exists("g:loaded_vorax") 
  finish
endif

" check for tlib
runtime plugin/*tlib*.vim
if !exists('loaded_tlib') || loaded_tlib < 40
  echoerr 'tlib >= 0.40 is required'
  finish
endif

" Current VoraX version
let g:loaded_vorax = "3.0.0"

" Compatibility stuff handling
let s:keep_cpo = &cpo
set cpo&vim

" *** BOOTSTRAP SECTION {{{
" ==============================================================================
" Check Vim version
if v:version < 703
  echo "***warning*** this version of VoraX needs vim 7.3"
  finish
endif

" Basic ruby prerequisites check
if !has('ruby')
  " check for ruby support
  echo "***warning*** VoraX needs ruby support"
  finish
else
  " is it ruby 1.8?
  let rver = ''
  ruby VIM.command("let rver='" + RUBY_VERSION + "'")
  let rver_parts = split(rver, '\.')
  if type(rver_parts) ==  3 && len(rver_parts) >= 3
    if (rver_parts[0] == '1' && rver_parts[1] == '8' && rver_parts[2] == '7') ||
          \ (rver_parts[0] == '1' && rver_parts[1] == '9')
      " good to go
    else
      echo "***warning*** VoraX needs ruby 1.8.7 " .
            \ "or ruby 1.9 support. Found " . rver
      finish
    endif
  else
    echo "***warning*** Could not detect the version " .
          \ "of your ruby support."
    finish
  endif
endif

" Define an autocommands group just for VoraX
augroup VoraX

" load the ruby helper
exe "ruby $:.unshift '" . expand('<sfile>:h:p') . 
      \ '/../vorax/ruby-helper/lib' . "'"
exe 'ruby require "vorax"'

" ==============================================================================
" *** END OF BOOTSTRAP SECTION *** }}}

" *** CONFIGURATION SECTION 
" ==============================================================================
" g:vorax_home_dir {{{
if !exists('g:vorax_home_dir') 
  " The VoraX home directory where various config files are kept.
  " Don't like poluting user's HOME directory therefore, by default, create a 
  " .vorax folder directly under HOME.
  let g:vorax_home_dir = substitute(expand('$HOME') . '/.vorax', 
        \ '\\\\\|\\', '/', 'g')
  if finddir(g:vorax_home_dir, '') == ''
    call mkdir(g:vorax_home_dir, '')
  endif
endif " }}}
" g:vorax_debug_level {{{
if !exists('g:vorax_debug_level') 
  " The default debug/logging level. The following levels are available:
  " ALL, TRACE, DEBUG, INFO, WARN, ERROR, FATAL, NONE
  " This feature relies on the [log.vim] plugin, from: 
  "
  " http://www.vim.org/scripts/script.php?script_id=2330
  "
  " The log plugin should reside in the autoload directory.
  let g:vorax_debug_level = 'NONE'
else
	if g:vorax_debug_level != 'NONE'
    " initialize logging
    silent! runtime autoload/log.vim
    if exists("*log#init")
      call log#init(g:vorax_debug_level, [g:vorax_home_dir . '/vorax.log'])
    else
      " log.vim script is not installed. Warn user about it.
      call voraxlib#utils#Warn("***warning*** log.vim script is needed " .
            \ "for debugging VoraX")
      call voraxlib#utils#Warn("1. Download it from: " .
            \ "http://www.vim.org/scripts/script.php?script_id=2330")
      call voraxlib#utils#Warn("2. Copy it into your .vim/autoload folder")
      call voraxlib#utils#Warn("3. Restart VoraX")
    endif
  endif
endif " }}}
" g:vorax_throbber_chars"{{{

" Default throbber symbols
TLet g:vorax_throbber_chars = ['.', 'o', 'O', '@', '*', ' ']

" }}}
" g:vorax_session_owner_monitor {{{

" How to get the user@db info. This info is usually displayed in the title
" and the status line. It helps the user to find out where is connected to. 
" The allowed values are:
"   0 = never    : VoraX will not update the title with the user@db info. In
"                  this case you must rely on other forms of displaying this 
"                  info. For example, you may configure in your login.sql file
"                  an sqlprompt with user@db into it.
"   1 = on login : VoraX will get the user@db info on connect only. This
"                  gives you the best balance of usefulness and performance.
"                  The drawback is that the title will not be updated on
"                  disconnects.
"   2 = always   : VoraX will get the user@db after every exec. The title is
"                  always kept in sync but this implies a performance
"                  penalty. Likewise, there are some issues with DBMS_XPLAN.
TLet g:vorax_session_owner_monitor = 1

" }}}
" g:vorax_limit_rows"{{{

" Limit the rows returned by interactive executed queries. This setting
" doesn't affect queries contained in sqlplus scripts. If this variable is
" greater than 0 then every query will be wrapped in a:
" select * from (<actual_query>) where rownum <= g:vorax_limit_rows.
TLet g:vorax_limit_rows = 0

"}}}
" g:vorax_limit_rows_show_warning"{{{

" Whenever or not to display a warning after every executed query in order to
" let know the user that a limit rows filter is active and the output might be
" truncated

TLet g:vorax_limit_rows_show_warning = 1

"}}}
" g:vorax_open_compilation_errors_command"{{{

" The command used to display the compilation errors using the quickfix window.
TLet g:vorax_open_compilation_errors_command = 'botright cwindow'

"}}}
" g:vorax_sqlplus_default_options"{{{

" Options to be set as soon as a new sqlplus process is started.
TLet g:vorax_sqlplus_default_options = ['set linesize 10000',
                                      \ 'set tab off',
                                      \ 'set flush on',
                                      \ 'set sqlprefix #',
                                      \ 'set blockterminator .',
                                      \ 'set pause off',
                                      \ 'set sqlblanklines on',]

"}}}
" g:vorax_sqlplus_pause_warning"{{{

" VoraX do not get along with the sqlplus PAUSE ON option. If this variable
" is 1 then a check is performed before every exec and a warning is
" displayed in case this option is enabled. If you don't care and you rely
" to the sqlplus SET PAUSE ON you can disable this warning.
TLet g:vorax_sqlplus_pause_warning = 1

"}}}
" g:vorax_keep_selection_after_exec"{{{

" Whenever or not to keep the current visual selection after the statement was
" executed. Does work only if the g:vorax_output_window_keep_focus_after_exec
" is 0.
TLet g:vorax_keep_selection_after_exec = 0

"}}}
" g:vorax_explain_options"{{{

" The options to be pased to DBMS_XPLAN in order to fetch the corresponding
" explain plan.
TLet g:vorax_explain_options = "ALLSTATS LAST +alias"

"}}}
" g:vorax_output_window_anchor"{{{

" The anchor of the output window. The allowed values are: topleft or
" botright.
TLet g:vorax_output_window_anchor = 'botright'

"}}}
" g:vorax_output_window_orientation"{{{

" The orientation of the output window. The allowed values are: 'v' for
" vertical and 'h' for horizontal.
TLet g:vorax_output_window_orientation = 'h'

"}}}
" g:vorax_output_window_size"{{{

" The size of the output window. 
TLet g:vorax_output_window_size = 15

"}}}
" g:vorax_output_window_keep_focus_after_exec"{{{

" Whenever or not, after executing a statement, the output window to remain
" focused. If 0 then the window from which the exec comes from is focused.
TLet g:vorax_output_window_keep_focus_after_exec = 0

"}}}
" g:vorax_output_window_pause"{{{

" wherever or not the results printed to the output window to be displayed
" page by page. After the first page is spit the execution is suspended.
" The user has the possibility to get the next page or to simply cancel the
" current request.
TLet g:vorax_output_window_pause = 0

"}}}
" g:vorax_output_window_page_size"{{{

" this global variable is used in connection with the
" g:vorax_output_window_pause and is used to configure how many lines a page
" should have. If g:vorax_output_window_pause is 1 then, after reaching the
" limit set by this variable, VoraX will stop writing into the output
" window until the user requests the next page. If
" g:vorax_output_window_page_size is 0 then the value is automatically computed 
" as the height of the output window. Negative values are not valid and
" they fall back to 0, with the above described meaning.
TLet g:vorax_output_window_page_size = 0

"}}}
" g:vorax_output_window_default_spool_file"{{{

" the default file to spool output window content. The value of this
" variable should be a valid VimL expression which evaluates to a valid file
" name. This expression is evaluated on every spooling activation.
TLet g:vorax_output_window_default_spool_file = 'g:vorax_home_dir."/".strftime("%Y-%m-%d").".spool"'

"}}}
" g:vorax_output_window_statusline"{{{

" The statusline definition for the output window. You are free to overwrite
" to whatever you want if you feel that the default provided one doesn't quite
" fit.
TLet g:vorax_output_window_statusline = "%!voraxlib#panel#output#StatusLine()"

"}}}
" g:vorax_output_window_clear_before_exec"{{{

" Whenever or not the output window should be cleared before executing
" anything.
TLet g:vorax_output_window_clear_before_exec = 1

"}}}
" g:vorax_output_window_column_underline_hi_group "{{{

" The highlight group to use for displaying the underline after each column
" when the result of a query is shown.
TLet g:vorax_output_window_column_underline_hi_group = 'Error'

"}}}
" g:vorax_output_window_feedback_hi_group "{{{

" The highlight group to use for displaying the feedback sqlplus message
TLet g:vorax_output_window_feedback_hi_group = 'Directory'

"}}}
" g:vorax_output_window_error_hi_group "{{{

" The highlight group to use for displaying errors
TLet g:vorax_output_window_error_hi_group = 'ErrorMsg'

"}}}
" g:vorax_output_window_force_column_heading "{{{

" Whenever or not VoraX will try to format columns so that their
" headings to be displayed without being truncated (a common problem 
" in sqlplus).
TLet g:vorax_output_window_force_column_heading = 0

"}}}
" g:vorax_oradoc_window_anchor"{{{

" The anchor of the oradoc window. The allowed values are: topleft or
" botright.
TLet g:vorax_oradoc_window_anchor = 'botright'

"}}}
" g:vorax_oradoc_window_orientation"{{{

" The orientation of the oradoc window. The allowed values are: 'v' for
" vertical and 'h' for horizontal.
TLet g:vorax_oradoc_window_orientation = 'h'

"}}}
" g:vorax_oradoc_window_size"{{{

" The size of the oradoc window. 
TLet g:vorax_oradoc_window_size = 10

"}}}
" g:vorax_oradoc_window_autoclose"{{{

" Whenever or not to automatically close the oradoc window after opening a
" help tag.
TLet g:vorax_oradoc_window_autoclose = 0

"}}}
" g:vorax_oradoc_index_file"{{{

" Where to store the oradoc index file
TLet g:vorax_oradoc_index_file = g:vorax_home_dir . '/vorax_oradoc.idx'

"}}}
" g:vorax_oradoc_config_file"{{{

" The oradoc config file (swish-e format).
TLet g:vorax_oradoc_config_file = substitute(
      \ fnamemodify(expand('<sfile>:p:h') . '/../vorax/oradoc/config/vorax_oradoc.conf', ':p:8'),
      \ '\\\\\|\\', '/', 'g')

"}}}
" g:vorax_oradoc_target_folder"{{{

" Where the Oracle HTML documentation is located by default.
TLet g:vorax_oradoc_target_folder = substitute(
      \ fnamemodify(expand('<sfile>:p:h') . '/../vorax/oradoc/public', ':p:8'),
      \ '\\\\\|\\', '/', 'g')

"}}}
" g:vorax_oradoc_open_with "{{{

if has('win32')
  TLet g:vorax_oradoc_open_with = 'silent! !start C:\Program Files\Internet Explorer\iexplore.exe %u'
elseif has('unix')
  " assume firefox executable is in your $PATH
  TLet g:vorax_oradoc_open_with = "silent! !firefox -remote 'ping()' > /dev/null 2>&1 && firefox -remote 'openURL(%u)' > /dev/null 2>&1 || firefox '%u' > /dev/null &2>1"
endif

"}}}
" g:vorax_profiles_window_anchor"{{{

" The anchor of the profile window. The allowed values are: topleft or
" botright.
TLet g:vorax_profiles_window_anchor = 'botright'

"}}}
" g:vorax_profiles_window_orientation"{{{

" The orientation of the profile window. The allowed values are: 'v' for
" vertical and 'h' for horizontal.
TLet g:vorax_profiles_window_orientation = 'v'

"}}}
" g:vorax_profiles_window_size"{{{

" The size of the profile window. 
TLet g:vorax_profiles_window_size = 30

"}}}
" g:vorax_explorer_window_anchor"{{{

" The anchor of the explorer window. The allowed values are: topleft or
" botright.
TLet g:vorax_explorer_window_anchor = 'botright'

"}}}
" g:vorax_explorer_window_orientation"{{{

" The orientation of the explorer window. The allowed values are: 'v' for
" vertical and 'h' for horizontal.
TLet g:vorax_explorer_window_orientation = 'v'

"}}}
" g:vorax_explorer_window_size"{{{

" The size of the explorer window. 
TLet g:vorax_explorer_window_size = 30

"}}}
" g:vorax_explorer_file_extensions"{{{

" Configures the file extension for every database
" object type. If a type is not here then the .sql
" extension will be assumed.
TLet g:vorax_explorer_file_extensions =     {'PACKAGE' : 'pkg',
                                      \     'PACKAGE_SPEC' : 'spc',
                                      \     'PACKAGE_BODY' : 'bdy',
                                      \     'FUNCTION' : 'fnc',
                                      \     'PROCEDURE' : 'prc',
                                      \     'TRIGGER' : 'trg',
                                      \     'TYPE' : 'typ',
                                      \     'TYPE_SPEC' : 'tps',
                                      \     'TYPE_BODY' : 'tpb',
                                      \     'TABLE' : 'tab',
                                      \     'VIEW' : 'viw',}

"}}}
" g:vorax_omni_word_prefix_length"{{{

" How many chars to type before suggesting completion items
TLet g:vorax_omni_word_prefix_length = 2

"}}}
" g:vorax_omni_skip_prefixes"{{{

" If the completion prefix matches the following regexp just skip it.
TLet g:vorax_omni_skip_prefixes = '^sys\.$'

"}}}
" g:vorax_omni_guess_columns_without_alias "{{{

" Whenever or not Vorax will try to figure out from what tables do you intend
" to query and will suggest columns based on this asumption.
TLet g:vorax_omni_guess_columns_without_alias = 1

"}}}
" g:vorax_force_keymappings"{{{

" Whenever or not a VoraX defined mapping to overwrite an already defined
" mapping by another plugin.
TLet g:vorax_force_keymappings = 1

"}}}
" g:vorax_test_constr"{{{

" This global variable is used by vorax unit tests. Ignore it if you do not
" intend to run the test suite.
TLet g:vorax_test_constr = 'vorax/vorax@your_db'

"}}}
" ==============================================================================

" *** COMMANDS SECTION
" ==============================================================================
" :VoraxConnect"{{{
if exists(':VoraxConnect') != 2
  command! -nargs=? -count=0 -complete=customlist,voraxlib#panel#profiles#ProfilesForCompletion 
        \ -bang VoraxConnect :call vorax#Connect(<q-args>, '<bang>')
  nmap <unique> <script> <Plug>VoraxConnect :VoraxConnect<CR>
endif"}}}
" :VoraxExec"{{{
if !exists(':VoraxExec')
  command! -nargs=1 VoraxExec :call vorax#Exec(<q-args>)
  nmap <unique> <script> <Plug>VoraxExec :VoraxExec<CR>
endif"}}}
" :VoraxDescribe"{{{
if exists(':VoraxDescribe') != 2
  command! -nargs=? VoraxDescribe :call vorax#Describe(<q-args>, 0)
  nmap <unique> <script> <Plug>VoraxDescribe :VoraxDescribe<CR>
endif"}}}
" :VoraxDescribeVerbose"{{{
if exists(':VoraxDescribeVerbose') != 2
  command! -nargs=? VoraxDescribeVerbose :call vorax#Describe(<q-args>, 1)
  nmap <unique> <script> <Plug>VoraxDescribeVerbose :VoraxDescribeVerbose<CR>
endif"}}}
" :VoraxExplain"{{{
if exists(':VoraxExplain') != 2
  command! -nargs=? VoraxExplain :call vorax#Explain(<q-args>, 0)
  nmap <unique> <script> <Plug>VoraxExplain :VoraxExplain<CR>
endif"}}}
" :VoraxExplainOnly"{{{
if exists(':VoraxExplainOnly') != 2
  command! -nargs=? VoraxExplainOnly :call vorax#Explain(<q-args>, 1)
  nmap <unique> <script> <Plug>VoraxExplainOnly :VoraxExplainOnly<CR>
endif"}}}
" :VoraxOradoc"{{{
if exists(':VoraxOradocSearch') != 2
  command! -nargs=? VoraxOradocSearch :call voraxlib#oradoc#Search(<q-args>)
  nmap <unique> <script> <Plug>VoraxOradocSearch :VoraxOradocSearch<CR>
endif"}}}
" :VoraxOradocCreateIndex"{{{
if exists(':VoraxOradocCreateIndex') != 2
  command! -nargs=? VoraxOradocCreateIndex :call voraxlib#oradoc#CreateIndex(<q-args>)
  nmap <unique> <script> <Plug>VoraxOradocCreateIndex :VoraxOradocCreateIndex<CR>
endif"}}}
" :VoraxScratch"{{{
if exists(':VoraxScratch') != 2
  command! -nargs=0 VoraxScratch :call vorax#NewSqlScratch()
  nmap <unique> <script> <Plug>VoraxScratch :VoraxScratch<CR>
endif"}}}
" :VoraxCompileBuffer"{{{
if exists(':VoraxCompileBuffer') != 2
  command! -nargs=0 VoraxCompileBuffer :call vorax#CompileBuffer()
  nmap <unique> <script> <Plug>VoraxCompileBuffer :VoraxCompileBuffer<CR>
endif"}}}
" :VoraxExecCurrent"{{{
if exists(':VoraxExecCurrent') != 2
  command! -nargs=0 -bar VoraxExecCurrent :call vorax#ExecCurrent()
  nmap <unique> <script> <Plug>VoraxExecCurrent :VoraxExecCurrent<CR>
endif"}}}
" :VoraxExecSelection"{{{
if exists(':VoraxExecSelection') != 2
  command! -nargs=0 -bar -range VoraxExecSelection :call vorax#ExecSelection()
  xmap <unique> <script> <Plug>VoraxExecSelection :VoraxExecSelection<CR>
endif"}}}
" :VoraxExplainSelection"{{{
if exists(':VoraxExplainSelection') != 2
  command! -nargs=0 -bar -range VoraxExplainSelection :call vorax#Explain(voraxlib#utils#SelectedBlock(), 0)
  xmap <unique> <script> <Plug>VoraxExplainSelection :VoraxExplainSelection<CR>
endif"}}}
" :VoraxExplainOnlySelection"{{{
if exists(':VoraxExplainOnlySelection') != 2
  command! -nargs=0 -bar -range VoraxExplainOnlySelection :call vorax#Explain(voraxlib#utils#SelectedBlock(), 1)
  xmap <unique> <script> <Plug>VoraxExplainOnlySelection :VoraxExplainOnlySelection<CR>
endif"}}}
" :VoraxProfilesWindowToggle"{{{
if exists(':VoraxProfilesWindowToggle') != 2
  command! -nargs=0 -bar VoraxProfilesWindowToggle 
        \:call vorax#GetProfilesHandler().Toggle()
  nmap <unique> <script> <Plug>VoraxProfilesWindowToggle 
        \:VoraxProfilesWindowToggle<CR>
endif"}}}
" :VoraxExplorerWindowToggle"{{{
if exists(':VoraxExplorerWindowToggle') != 2
  command! -nargs=0 -bar VoraxExplorerWindowToggle 
        \:call vorax#GetExplorerHandler().Toggle()
  nmap <unique> <script> <Plug>VoraxExplorerWindowToggle 
        \:VoraxExplorerWindowToggle<CR>
endif"}}}
" :VoraxSpoolingToggle"{{{
if exists(':VoraxSpoolingToggle') != 2
  command! -nargs=0 -bar VoraxSpoolingToggle :call vorax#ToggleSpooling()
  nmap <unique> <script> <Plug>VoraxSpoolingToggle :VoraxSpoolingToggle<CR>
endif"}}}
" :VoraxCompressedOutputToggle"{{{
if exists(':VoraxCompressedOutputToggle') != 2
  command! -nargs=0 -bar VoraxCompressedOutputToggle :call vorax#ToggleCompressedOutput()
  nmap <unique> <script> <Plug>VoraxCompressedOutputToggle :VoraxCompressedOutputToggle<CR>
endif"}}}
" :VoraxVerticalOutputToggle"{{{
if exists(':VoraxVerticalOutputToggle') != 2
  command! -nargs=0 -bar VoraxVerticalOutputToggle :call vorax#ToggleVerticalOutput()
  nmap <unique> <script> <Plug>VoraxVerticalOutputToggle :VoraxVerticalOutputToggle<CR>
endif"}}}
" :VoraxLimitRowsToggle"{{{
if exists(':VoraxLimitRowsToggle') != 2
  command! -nargs=0 VoraxLimitRowsToggle :call vorax#ToggleLimitRows()
  nmap <unique> <script> <Plug>VoraxLimitRowsToggle :VoraxLimitRowsToggle<CR>
endif"}}}
" :VoraxPaginatingToggle"{{{
if exists(':VoraxPaginatingToggle') != 2
  command! -nargs=0 VoraxPaginatingToggle :call vorax#TogglePaginating()
  nmap <unique> <script> <Plug>VoraxPaginatingToggle :VoraxPaginatingToggle<CR>
endif"}}}
" :VoraxOutputWindowToggle"{{{
if exists(':VoraxOutputWindowToggle') != 2
  command! -nargs=0 VoraxOutputWindowToggle :call vorax#ToggleOutputWindow()
  nmap <unique> <script> <Plug>VoraxOutputWindowToggle :VoraxOutputWindowToggle<CR>
endif"}}}

" ==============================================================================

" *** KEY MAPPINGS SECTION 
" ==============================================================================
" g:vorax_exec_key"{{{
TLet g:vorax_exec_key = "<Leader>e"
"}}}
" g:vorax_describe_key"{{{
TLet g:vorax_describe_key = "<Leader>d"
"}}}
" g:vorax_describe_verbose_key"{{{
TLet g:vorax_describe_verbose_key = "<Leader>D"
"}}}
" g:vorax_explain_key"{{{
TLet g:vorax_explain_key = "<Leader>x"
"}}}
" g:vorax_explain_only_key"{{{
TLet g:vorax_explain_only_key = "<Leader>X"
"}}}
" g:vorax_scratch_key"{{{
TLet g:vorax_scratch_key = "<Leader>ss"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_scratch_key . " <Plug>VoraxScratch"
"}}}
" g:vorax_spooling_toggle_key"{{{
TLet g:vorax_spooling_toggle_key = "<Leader>sp"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_spooling_toggle_key . " <Plug>VoraxSpoolingToggle"
"}}}
" g:vorax_compressed_output_toggle_key"{{{
TLet g:vorax_compressed_output_toggle_key = "<Leader>co"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_compressed_output_toggle_key . " <Plug>VoraxCompressedOutputToggle"
"}}}
" g:vorax_vertical_output_toggle_key"{{{
TLet g:vorax_vertical_output_toggle_key = "<Leader>vo"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_vertical_output_toggle_key . " <Plug>VoraxVerticalOutputToggle"
"}}}
" g:vorax_limit_rows_toggle_key"{{{
TLet g:vorax_limit_rows_toggle_key = "<Leader>lr"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_limit_rows_toggle_key . " <Plug>VoraxLimitRowsToggle"
"}}}
" g:vorax_paginating_toggle_key"{{{
TLet g:vorax_paginating_toggle_key = "<Leader>pa"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_paginating_toggle_key . " <Plug>VoraxPaginatingToggle"
"}}}
" g:vorax_output_window_clear_key"{{{
TLet g:vorax_output_window_clear_key = "cle"
"}}}
" g:vorax_output_window_pause_key"{{{
TLet g:vorax_output_window_pause_key = "<Space>"
"}}}
" g:vorax_output_window_toggle_show"{{{
TLet g:vorax_output_window_toggle_show = "<Leader>o"
exe "nmap <silent> " . (g:vorax_output_window_toggle_show ? "" : "<unique> ") . g:vorax_output_window_toggle_show . " <Plug>VoraxOutputWindowToggle"
"}}}
" g:vorax_output_window_toggle_append"{{{
TLet g:vorax_output_window_toggle_append = "<Leader>a"
"}}}
" g:vorax_output_window_toggle_column_headings"{{{
TLet g:vorax_output_window_toggle_column_headings = "<Leader>ch"
"}}}
" g:vorax_profiles_window_toggle_key"{{{
TLet g:vorax_profiles_window_toggle_key = "<Leader>pr"
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_profiles_window_toggle_key . " <Plug>VoraxProfilesWindowToggle"
"}}}
" g:vorax_profiles_window_menu_key"{{{
TLet g:vorax_profiles_window_menu_key = "<Tab>"
"}}}
" g:vorax_explorer_window_toggle_key"{{{
TLet g:vorax_explorer_window_toggle_key = "<Leader>ve"
exe "nmap <unique> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_explorer_window_toggle_key . " <Plug>VoraxExplorerWindowToggle"
"}}}
" g:vorax_explorer_window_menu_key"{{{
TLet g:vorax_explorer_window_menu_key = "<Tab>"
"}}}
" g:vorax_explorer_window_refresh_key"{{{
TLet g:vorax_explorer_window_refresh_key = "R"
"}}}
" g:vorax_compile_plsql_buffer_key {{{
TLet g:vorax_compile_plsql_buffer_key = '<F9>'
"}}}
" g:vorax_oradoc_search_key {{{
TLet g:vorax_oradoc_search_key = '<Leader>h'
exe "nmap <silent> " . (g:vorax_force_keymappings ? "" : "<unique> ") . g:vorax_oradoc_search_key . " <Plug>VoraxOradocSearch"
"}}}
" g:vorax_oradoc_undercursor_key {{{
TLet g:vorax_oradoc_undercursor_key = 'K'
"}}}
" ==============================================================================

" *** AUTOCOMMANDS SECTION 
" ==============================================================================
" filetype detection {{{
if exists('g:vorax_explorer_file_extensions')
  " Set the proper file type
  let sqlext = []
  let plsqlext = []
  for key in keys(g:vorax_explorer_file_extensions)
    if key == 'PACKAGE' ||
          \ key == 'PACKAGE_SPEC' ||
          \ key == 'PACKAGE_BODY' ||
          \ key == 'TYPE' ||
          \ key == 'TYPE_SPEC' ||
          \ key == 'TYPE_BODY' ||
          \ key == 'TRIGGER' ||
          \ key == 'FUNCTION' ||
          \ key == 'PROCEDURE'
      " plsql buffers
      call add(plsqlext, g:vorax_explorer_file_extensions[key])
    else
      " sql buffers
      call add(sqlext, g:vorax_explorer_file_extensions[key])
    endif
  endfor
  if !empty(sqlext)
    exe 'autocmd BufRead,BufNewFile *.{' . join(sqlext, ',') . '} set ft=sql'
  endif
  if !empty(plsqlext)
    exe 'autocmd BufRead,BufNewFile *.{' . join(plsqlext, ',') . '} set ft=plsql'
  endif
endif "}}}
" ==============================================================================

" Restore compatibility flag
let &cpo = s:keep_cpo
unlet s:keep_cpo

