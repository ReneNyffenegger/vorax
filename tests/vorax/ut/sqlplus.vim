" Test a complete initialization/destroy process.
function! TestVoraxSqlplusLifeCycle()
  " initialize oracle object
  let sqlplus = voraxlib#sqlplus#New()
  let pid = sqlplus.GetPid()
  " test if the sqlplus pid is returned
  call VUAssertTrue(pid != -1, 'Test for pid')
  " the banner
  call VUAssertTrue(sqlplus.GetBanner() =~ 'SQL\*Plus', 'Test banner')
  " test run dir
  call VUAssertTrue(sqlplus.GetTempDir() != '', 'Test rundir')
  " destroy the process at the end
  call sqlplus.Destroy()
  " is this pid still there?
  if  has('unix')
    ruby begin; Process.kill(0, VIM::evaluate('pid')); VIM::command('call VUAssertFail("Pid exists after destroy.")'); rescue Errno::ESRCH; end
  elseif has('win32') || has('win64')
    let output = system('tasklist /FI "PID eq ' . pid . '"')
    if output !~ 'No tasks running'
      call VUAssertFail("Pid exists after destroy")
    endif
  endif
endfunction

" Test the session owner monitor feature.
function! TestVoraxSqlplusSessionOwnerMonitor()
  let sqlplus = voraxlib#sqlplus#New()
  " test always policy
  call sqlplus.SetSessionOwnerMonitor(2)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 2, 'Test session owner policy to always')
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@', 'Test session owner policy always after connect')
  call sqlplus.Exec('disconnect')
  call VUAssertTrue(sqlplus.GetConnectedTo() == '@', 'Test session owner policy always after disconnect')
  " test none policy
  call sqlplus.SetSessionOwnerMonitor(0)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 0, 'Test session owner policy never')
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() == '@', 'Test session owner policy never after connect')
  " test on_login policy
  call sqlplus.SetSessionOwnerMonitor(1)
  call VUAssertTrue(sqlplus.GetSessionOwnerMonitor() == 1, 'Test session owner policy on_login')
  call sqlplus.Exec('connect ' . g:vorax_test_constr)
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@', 'Test session owner policy on_login after connect')
  call sqlplus.Exec('disconnect')
  call VUAssertTrue(sqlplus.GetConnectedTo() != '@', 'Test session owner policy on_login after disconnect')
  call sqlplus.Destroy()
endfunction

" Test the exec feature.
function! TestVoraxSqlplusExec()
  let sqlplus = voraxlib#sqlplus#New()
  " test default read buffer setting
  call sqlplus.SetDefaultReadBufferSize(8192)
  call VUAssertTrue(sqlplus.GetDefaultReadBufferSize() == 8192, 'Test set read buffer size to 8192')
  " test basic exec
  call VUAssertTrue(sqlplus.Exec("prompt talek's vorax") =~ "talek's vorax", 'Test basic exec')
  " test with options preserved
  call sqlplus.Exec('set sqlprompt "SQL> "')
  let output = sqlplus.Exec("show sqlprompt", {'sqlplus_options' : [{'option' : 'sqlprompt', 'value' : '"vorax_muci> "'}] })
  call VUAssertTrue(output =~ 'vorax_muci> ', 'Test vorax_muci> output')
  call VUAssertTrue(sqlplus.GetConfigFor('sqlprompt')[0] =~ 'SQL> ', 'Test if the sqlprompt is preserved.')
  " test non-block exec/read stuff
  call sqlplus.NonblockExec('prompt "nonblock_test"')
  call VUAssertTrue(sqlplus.IsBusy(), 'Test IsBusy()')
  let output = ''
  while sqlplus.IsBusy()
    let output .= sqlplus.Read(1024)
  endwhile
  call VUAssertTrue(output =~ '"nonblock_test"', 'test nonblock')

  " test send text
  call sqlplus.NonblockExec("prompt abcdefg\n")
  let output = ''
  while sqlplus.IsBusy()
    let output .= sqlplus.Read()
  endwhile
  call VUAssertTrue(output =~ 'abcdefg', 'test output nonblock')
  call sqlplus.Destroy()
endfunction

" Test get config for an sqlplus option.
function! TestVoraxSqlplusGetConfigFor()
  let sqlplus = voraxlib#sqlplus#New()
  call VUAssertTrue(join(sqlplus.GetConfigFor('linesize', 'pagesize')) =~ 'set linesize [0-9]\+ set pagesize [0-9]\+', 'Test getconfigfor 1')
  " test a very long setting
  call sqlplus.Exec('set markup HTML OFF HEAD "<style type=''text/css''> body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}</style><title>SQL*Plus Report</title>" BODY "" TABLE "border=''1'' width=''90%'' align=''center'' summary=''Script output''" SPOOL OFF ENTMAP ON PRE OFF')
  call VUAssertTrue(sqlplus.GetConfigFor('markup')[0] =~ 'ON PRE OFF$')
  call sqlplus.Destroy()
endfunction

" Test the pack feature
function! TestVoraxSqlplusPack()
  let sqlplus = voraxlib#sqlplus#New()
  " pack as an array of commands
  call VUAssertTrue(sqlplus.Pack(['set linesize 1000', 'select * from cat;'], {'target_file' : 'my_pack_file.sql'}) == '@' . sqlplus.GetTempDir(). '/my_pack_file.sql', 'Test pack 1')
  " pack as CR delimited list of commands
  call VUAssertTrue(sqlplus.Pack("set linesize 1000\nselect * from cat;", {'target_file': 'my_pack_file.sql'}) == '@'.sqlplus.GetTempDir().'/my_pack_file.sql', 'Test pack 2')
  call sqlplus.Destroy()
endfunction


