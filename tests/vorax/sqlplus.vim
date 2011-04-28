UTSuite [voraxlib#sqlplus] Testing the sqlplus layer

" initialize oracle object
let sqlplus = voraxlib#sqlplus#New()

" test if the sqlplus pid is returned
Assert sqlplus.GetPid() != -1

" the banner
Assert sqlplus.GetBanner() =~ 'SQL\*Plus'

" test session owner monitor
call sqlplus.SetSessionOwnerMonitor(2)
Assert sqlplus.GetSessionOwnerMonitor() == 2
call sqlplus.SetSessionOwnerMonitor(0)
Assert sqlplus.GetSessionOwnerMonitor() == 0

" test default read buffer setting
call sqlplus.SetDefaultReadBufferSize(8192)
Assert sqlplus.GetDefaultReadBufferSize() == 8192

" basic test for GetConnectedTo
Assert sqlplus.GetConnectedTo() == '@'

" test run dir
Assert sqlplus.GetRunDir() != ''

" test basic exec
Assert sqlplus.Exec("prompt talek's vorax") =~ "talek's vorax"

" non-block exec/read stuff
call sqlplus.NonblockExec('prompt "nonblock_test"')
let output = ''
while sqlplus.IsBusy()
  let output .= sqlplus.Read(1024)
endwhile
Assert output =~ '"nonblock_test"'

" test send text
call sqlplus.NonblockExec("prompt abcdefg\n")
let output = ''
while sqlplus.IsBusy()
  let output .= sqlplus.Read()
endwhile
Assert output =~ 'abcdefg'

" test config_for
Assert join(sqlplus.GetConfigFor('linesize', 'pagesize')) =~ 'set linesize [0-9]\+ set pagesize [0-9]\+'

" test pack
Assert sqlplus.Pack(['set linesize 1000', 'select * from cat;'], 'my_pack_file.sql') == '@my_pack_file.sql'

" destroy the process at the end
call sqlplus.Destroy()

