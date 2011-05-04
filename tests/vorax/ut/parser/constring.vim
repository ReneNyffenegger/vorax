function! TestVoraxParserConstring()
  call VUAssertEquals(voraxlib#parser#constring#Split('user/pwd@db'),
                    \ {'user' : 'user', 'passwd' : 'pwd', 'db' : 'DB', 'osauth' : 0},
                    \ 'Simple test to parse a basic connection string.')
  call VUAssertEquals(voraxlib#parser#constring#Split('"marius teicu"/"muHaHa"@mydb as sysdba'),
                    \ {'user' : '"marius teicu"', 'passwd' : '"muHaHa"', 'db' : 'MYDB AS SYSDBA', 'osauth' : 0},
                    \ 'A test to parse a connection string with case sensitive user/password and a sysdba modifier.')
  call VUAssertEquals(voraxlib#parser#constring#Split('/ as sysdba'),
                    \ {'user' : '/ as sysdba', 'passwd' : '', 'db' : '', 'osauth' : 1},
                    \ 'Test the OS authentication')
  call VUAssertEquals(voraxlib#parser#constring#Split('sys/xxx@hen:1521/easydb'),
                    \ {'user' : 'sys', 'passwd' : 'xxx', 'db' : 'HEN:1521/EASYDB', 'osauth' : 0},
                    \ 'Test an EZ connect string.')
endfunction


