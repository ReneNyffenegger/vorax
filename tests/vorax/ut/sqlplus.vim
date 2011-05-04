" Test a complete initialization/destroy process.
function! TestVoraxSqlplusLifeCycle()
  " initialize oracle object
  let sqlplus = voraxlib#sqlplus#New()
  let pid = sqlplus.GetPid()
  " test if the sqlplus pid is returned
  call VUAssertTrue(pid != -1)
  " the banner
  call VUAssertTrue(sqlplus.GetBanner() =~ 'SQL\*Plus')
  " test run dir
  call VUAssertTrue(sqlplus.GetRunDir() != '')
  " destroy the process at the end
  call sqlplus.Destroy()
  " is this pid still there?
  ruby begin; Process.getpgid(VIM::evaluate('pid')); VIM::command('call VUAssertFail("Pid exists after destroy.")'); rescue Errno::ESRCH; end
endfunction

" Test the session owner monitor feature.
function! TestVoraxSqlplusSessionOwnerMonitor()
  let sqlplus = voraxlib#sqlplus#New()
  " test always policy
  call sqlplus.SetSessionOwnerMonitor(2)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 2)
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@')
  call sqlplus.Exec('disconnect')
  call VUAssertTrue(sqlplus.GetConnectedTo() == '@')
  " test none policy
  call sqlplus.SetSessionOwnerMonitor(0)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 0)
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() == '@')
  " test on_login policy
  call sqlplus.SetSessionOwnerMonitor(1)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 1)
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@')
  call sqlplus.Exec('disconnect')
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@')
  call sqlplus.Destroy()
endfunction

" Test the exec feature.
function! TestVoraxSqlplusExec()
  let sqlplus = voraxlib#sqlplus#New()
  " test default read buffer setting
  call sqlplus.SetDefaultReadBufferSize(8192)
  call VUAssertTrue(sqlplus.GetDefaultReadBufferSize() == 8192)
  " test basic exec
  call VUAssertTrue(sqlplus.Exec("prompt talek's vorax") =~ "talek's vorax")
  " test with options preserved
  call sqlplus.Exec('set sqlprompt "SQL> "')
  let output = sqlplus.Exec("prompt abc", {'sqlplus_options' : [{'option' : 'sqlprompt', 'value' : '"vorax_muci> "'}] })
  call VUAssertTrue(output =~ 'vorax_muci> ')
  call VUAssertTrue(sqlplus.GetConfigFor('sqlprompt')[0] =~ 'SQL> ')
  " test non-block exec/read stuff
  call sqlplus.NonblockExec('prompt "nonblock_test"')
  call VUAssertTrue(sqlplus.IsBusy())
  let output = ''
  while sqlplus.IsBusy()
    let output .= sqlplus.Read(1024)
  endwhile
  call VUAssertTrue(output =~ '"nonblock_test"')

  " test send text
  call sqlplus.NonblockExec("prompt abcdefg\n")
  let output = ''
  while sqlplus.IsBusy()
    let output .= sqlplus.Read()
  endwhile
  call VUAssertTrue(output =~ 'abcdefg')
  call sqlplus.Destroy()
endfunction

" Test get config for an sqlplus option.
function! TestVoraxSqlplusGetConfigFor()
  let sqlplus = voraxlib#sqlplus#New()
  call VUAssertTrue(join(sqlplus.GetConfigFor('linesize', 'pagesize')) =~ 'set linesize [0-9]\+ set pagesize [0-9]\+')
  call sqlplus.Destroy()
endfunction

" Test the pack feature
function! TestVoraxSqlplusPack()
  let sqlplus = voraxlib#sqlplus#New()
  " pack as an array of commands
  call VUAssertTrue(sqlplus.Pack(['set linesize 1000', 'select * from cat;'], 'my_pack_file.sql') == '@my_pack_file.sql')
  " pack as CR delimited list of commands
  call VUAssertTrue(sqlplus.Pack("set linesize 1000\nselect * from cat;", 'my_pack_file.sql') == '@my_pack_file.sql')
  call sqlplus.Destroy()
endfunction


