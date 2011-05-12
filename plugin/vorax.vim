" VoraX:      an oracle IDE under vim
" Author:     Alexandru Tică
" Date:	      15/04/10 14:08:20  
" Copyright:  Copyright (C) 2010 Alexandru Tică
"             Apache License, Version 2.0
"             http://www.apache.org/licenses/LICENSE-2.0.html

if exists("g:loaded_vorax") 
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
  call voraxlib#utils#Warn("***warning*** this version of VoraX needs vim 7.3")
  finish
endif

" Basic ruby prerequisites check
if !has('ruby')
  " check for ruby support
  call voraxlib#utils#Warn("***warning*** VoraX needs ruby support")
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
      call voraxlib#utils#Warn("***warning*** VoraX needs ruby 1.8.7 " .
            \ "or ruby 1.9 support. Found " . rver)
      finish
    endif
  else
    call voraxlib#utils#Warn("***warning*** Could not detect the version " .
          \ "of your ruby support.")
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
if !exists('g:vorax_throbber_chars')
  let g:vorax_throbber_chars = ['.', 'o', 'O', '@', '*', ' ']
endif"}}}
" g:vorax_session_owner_monitor {{{
if !exists('g:vorax_session_owner_monitor') 
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
  let g:vorax_session_owner_monitor = 1
endif " }}}
" g:vorax_sqlplus_default_options"{{{
if !exists('g:vorax_sqlplus_default_options')
  let g:vorax_sqlplus_default_options = ['set linesize 10000',
                                       \ 'set tab off',
                                       \ 'set flush on',]
endif"}}}
" g:vorax_statement_highlight_group"{{{
if !exists('g:vorax_statement_highlight_group')
	" The highlight group to be used when the currently executing statement is
	" highlighted. If you want to disable this feature then set this global
	" variable on an empty string.
	let g:vorax_statement_highlight_group = 'TODO'
endif"}}}
" g:vorax_output_window_anchor"{{{
if !exists('g:vorax_output_window_anchor')
	" The anchor of the output window. The allowed values are: topleft or
	" botright.
	let g:vorax_output_window_anchor = 'botright'
endif"}}}
" g:vorax_output_window_orientation"{{{
if !exists('g:vorax_output_window_orientation')
  " The orientation of the output window. The allowed values are: 'v' for
  " vertical and 'h' for horizontal.
  let g:vorax_output_window_orientation = 'h'
endif"}}}
" g:vorax_output_window_size"{{{
if !exists('g:vorax_output_window_size')
  " The size of the output window. 
  let g:vorax_output_window_size = 30
endif"}}}
" g:vorax_output_window_keep_focus_after_exec"{{{
if !exists('g:vorax_output_keep_focus_after_exec')
  " Whenever or not, after executing a statement, the output window to reamain
  " focused. If 0 then the window from which the exec comes from is focused.
  let g:vorax_output_window_keep_focus_after_exec = 0
endif"}}}
" g:vorax_profiles_window_anchor"{{{
if !exists('g:vorax_profiles_window_anchor')
	" The anchor of the profile window. The allowed values are: topleft or
	" botright.
	let g:vorax_profiles_window_anchor = 'botright'
endif"}}}
" g:vorax_profiles_window_orientation"{{{
if !exists('g:vorax_profiles_window_orientation')
  " The orientation of the profile window. The allowed values are: 'v' for
  " vertical and 'h' for horizontal.
  let g:vorax_profiles_window_orientation = 'v'
endif"}}}
" g:vorax_profiles_window_size"{{{
if !exists('g:vorax_profiles_window_size')
  " The size of the profile window. 
  let g:vorax_profiles_window_size = 30
endif"}}}
" g:vorax_test_constr"{{{
if !exists('g:vorax_test_constr')
	" This global variable is used by vorax unit tests. Ignore it if you do not
	" intend to run the test suite.
	let g:vorax_test_constr = 'vorax/vorax@your_db'
endif"}}}
" ==============================================================================

" *** COMMANDS SECTION
" ==============================================================================
" :VoraxConnect"{{{
if !exists(':VoraxConnect')
  command! -nargs=? -complete=customlist,vorax#ProfilesForCompletion 
        \ -bang VoraxConnect :call vorax#Connect(<q-args>, '<bang>')
  nmap <unique> <script> <Plug>VoraxConnect :VoraxConnect<CR>
endif"}}}
" :VoraxExec"{{{
if !exists(':VoraxExec')
  command! -nargs=? VoraxExec :call vorax#Exec(<q-args>)
  nmap <unique> <script> <Plug>VoraxExec :VoraxExec<CR>
endif"}}}
" :VoraxExecCurrent"{{{
if !exists(':VoraxExecCurrent')
  command! -nargs=0 VoraxExecCurrent :call vorax#ExecCurrent()
  nmap <unique> <script> <Plug>VoraxExecCurrent :VoraxExecCurrent<CR>
endif"}}}
" :VoraxExecSelection"{{{
if !exists(':VoraxExecSelection')
  command! -nargs=0 -range VoraxExecSelection :call vorax#ExecSelection()
  xmap <unique> <script> <Plug>VoraxExecSelection :VoraxExecSelection<CR>
endif"}}}
" :VoraxProfilesWindowToggle"{{{
if !exists(':VoraxProfilesWindowToggle')
  command! -nargs=0 VoraxProfilesWindowToggle 
        \:call vorax#GetProfilesHandler().Toggle()
  nmap <unique> <script> <Plug>VoraxProfilesWindowToggle 
        \:VoraxProfilesWindowToggle<CR>
endif"}}}
" ==============================================================================

" *** KEY MAPPINGS SECTION 
" ==============================================================================
" g:vorax_exec_key"{{{
if !exists('g:vorax_exec_key')
  let g:vorax_exec_key = "<Leader>e"
endif"}}}
" g:vorax_output_window_clear_key"{{{
if !exists('g:vorax_output_window_clear_key')
  let g:vorax_output_window_clear_key = "cle"
endif"}}}
" g:vorax_profiles_window_toggle_key"{{{
if !exists('g:vorax_profiles_window_toggle_key')
  let g:vorax_profiles_window_toggle_key = "<Leader>co"
endif
if g:vorax_profiles_window_toggle_key != '' 
      \ && !hasmapto('<Plug>VoraxProfilesWindowToggle') 
      \ && !hasmapto(g:vorax_profiles_window_toggle_key, 'n')
  exe "nmap <unique> " . g:vorax_profiles_window_toggle_key . 
        \ " <Plug>VoraxProfilesWindowToggle"
endif"}}}
" g:vorax_profiles_window_menu_key"{{{
if !exists('g:vorax_profiles_window_menu_key')
  let g:vorax_profiles_window_menu_key = "m"
endif"}}}
" ==============================================================================

" Restore compatibility flag
let &cpo = s:keep_cpo
unlet s:keep_cpo

