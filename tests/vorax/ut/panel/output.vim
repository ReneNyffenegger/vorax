let s:ut_dir = expand('<sfile>:h')

"function! TestVoraxOutputWindowAccept()
  "if g:vorax_test_gui
    "call VoraxCreateGuiBuddy()
    "call remote_send(g:vorax_test_gui_servername,
          "\ ':VoraxExec @' . s:ut_dir . '/../../sql/accept.sql<cr>')
    "if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && getline(1) == "Enter val: "')
      "" enter in insert mode
      "call remote_expr(g:vorax_test_gui_servername, "feedkeys('i')")
      "if IsGuiBuddyOk('line(".") == 1 && col(".") == 12')
        "call remote_expr(g:vorax_test_gui_servername, "feedkeys('abc\<cr>')")
        "if IsGuiBuddyOk('getbufline("__VoraxOutput__", 2)[0] == "The provided value was abc"')
        "else
          "call VUAssertFail('TestVoraxOutputWindowAccept(): The inputed value in accept does not correspond.')
        "endif
      "else
        "call VUAssertFail('TestVoraxOutputWindowAccept(): Incorrect cursor position in accept.')
      "endif
    "else
      "call VUAssertFail('TestVoraxOutputWindowAccept(): The output window did not show up!')
    "end
    "call VoraxKillGuiBuddy()
  "endif
"endfunction

"function! TestVoraxOutputWindowAcceptDiscard()
  "if g:vorax_test_gui
    "call VoraxCreateGuiBuddy()
    "call remote_send(g:vorax_test_gui_servername,
          "\ ':VoraxExec @' . s:ut_dir . '/../../sql/accept.sql<cr>')
    "if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && getline(1) == "Enter val: "')
      "" enter in insert mode
      "call remote_expr(g:vorax_test_gui_servername, "feedkeys('i')")
      "if IsGuiBuddyOk('line(".") == 1 && col(".") == 12')
        "call remote_expr(g:vorax_test_gui_servername, "feedkeys('abc\<Esc>')")
        "if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && getline(1) == "Enter val: "')
        "else
          "call VUAssertFail('TestVoraxOutputWindowAcceptDiscard(): The accept prompt wasn''t restored after Esc.')
        "endif
      "else
        "call VUAssertFail('TestVoraxOutputWindowAcceptDiscard(): Incorrect cursor position in accept.')
      "endif
    "else
      "call VUAssertFail('TestVoraxOutputWindowAcceptDiscard(): The output window did not show up!')
    "end
    "call VoraxKillGuiBuddy()
  "endif
"endfunction

function! TestVoraxOutputWindowCancelCall()
  if g:vorax_test_gui
    call VoraxCreateGuiBuddy()
    " cancel in an accept prompt
    call remote_send(g:vorax_test_gui_servername,
          \ ':VoraxExec @' . s:ut_dir . '/../../sql/accept.sql<cr>')
    if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && getline(1) == "Enter val: "')
      call remote_expr(g:vorax_test_gui_servername, "feedkeys('\<Esc>')")
      if IsGuiBuddyOk('getbufline("__VoraxOutput__", 1, "$")[-2] == "*** Cancelled ***"')
      else
        call VUAssertFail('TestVoraxOutputWindowCancelCall(): Call not cancelled!')
      endif
    else
      call VUAssertFail('TestVoraxOutputWindowCancelCall(): The output window did not show up!')
    end
    " cancel an incomplete command
    call remote_send(g:vorax_test_gui_servername,
          \ ':VoraxExec begin<cr>')
    if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && getbufline("__VoraxOutput__", 1, "$")[-1] =~ ''\s*3\s*''')
      call remote_expr(g:vorax_test_gui_servername, "feedkeys('\<Esc>')")
      if IsGuiBuddyOk('getbufline("__VoraxOutput__", 1, "$")[-2] == "*** Cancelled ***"')
      else
        call VUAssertFail('TestVoraxOutputWindowCancelCall(): A cancel was expected!')
      endif
    else
      call VUAssertFail('TestVoraxOutputWindowCancelCall(): A 3 was expected on the first line!')
    endif
    " cancel an in progress command
    call remote_send(g:vorax_test_gui_servername, ':let g:vorax_output_window_pause = 0<cr>')
    call remote_send(g:vorax_test_gui_servername,
          \ ':VoraxConnect ' . g:vorax_test_constr . ' | VoraxExec select * from all_objects;<cr>')
    if IsGuiBuddyOk('bufname("__VoraxOutput__") != "" && line(".") >= 100')
      call remote_expr(g:vorax_test_gui_servername, "feedkeys('\<Esc>')")
      if IsGuiBuddyOk('getbufline("__VoraxOutput__", 1, "$")[-2] == "*** Cancelled ***"')
      else
        call VUAssertFail('TestVoraxOutputWindowCancelCall(): A cancel was expected for the in progress query!')
      endif
    else
      call VUAssertFail('TestVoraxOutputWindowCancelCall(): The output window is not fill in as expected!')
    endif
    call VoraxKillGuiBuddy()
  endif
endfunction


