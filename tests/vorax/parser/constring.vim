UTSuite [voraxlib#parser#constring] Testing the connection string parser

" basic parsing
Assert voraxlib#parser#constring#Split('user/pwd@db') == {'user' : 'user', 'passwd' : 'pwd', 'db' : 'DB', 'osauth' : 0} 

" parsing with case sensitive user/pwd
Assert voraxlib#parser#constring#Split('"marius teicu"/"muHaHa"@mydb as sysdba') == {'user' : '"marius teicu"', 'passwd' : '"muHaHa"', 'db' : 'MYDB AS SYSDBA', 'osauth' : 0} 

" parsing OS auth
Assert voraxlib#parser#constring#Split('/ as sysdba') == {'user' : '/ as sysdba', 'passwd' : '', 'db' : '', 'osauth' : 1} 

" parsing using easy connect
Assert voraxlib#parser#constring#Split('sys/xxx@hen:1521/easydb') == {'user' : 'sys', 'passwd' : 'xxx', 'db' : 'HEN:1521/EASYDB', 'osauth' : 0}
