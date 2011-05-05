function! TestVoraxPanelProfiles()
  " delete all files from test vorax home directory
  call s:ClearVoraxHomeDir()
  
  " initialize the profiles manager
  let pm = voraxlib#panel#profiles#New()

  " check if the profiles secure repository is initialized
  call VUAssertTrue(pm.IsSecureRepositoryInitialized() == 0, 
                  \ 'Ups, the key files should not be there.')

  " create rsa files
  call pm.CreateSecureKeys('mucimuci')
  call VUAssertTrue(findfile('id_rsa', g:vorax_home_dir) != '' && findfile('id_rsa.pub', g:vorax_home_dir) != '', 
                  \ 'The CreateSecureKeys() did not create the key files.')
  call VUAssertTrue(pm.IsSecureRepositoryInitialized(), 
                  \ 'The secure repository should be initialized now.')

  " check if the profiles repository is unlocked
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 
                  \ 'The secure repository should be unlocked now.')

  " try to open with a wrong password
  call VUAssertTrue(pm.OpenMasterRepository('muci') == 0, 
                  \ 'The secure repository should not open with a wrong password.')

  " check if the profiles repository is unlocked
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 
                  \ 'After a wrong pwd, the secure repository should be locked now.')

  " open it with the good password
  call VUAssertTrue(pm.OpenMasterRepository('mucimuci') == 1, 
                  \ 'The secure repository should be openned now.')
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 
                  \ 'The secure repository should be unlocked now.')

  " add a new base profile without a password
  call pm.StoreProfile({'id' : 'talek@db'})
  call VUAssertTrue(pm.GetProfile('talek@db') == {'id' : 'talek@db'}, 
                  \ 'The new profile is not there.')

  " add a new profile into a category
  call pm.StoreProfile({'id' : 'talek2@db', 'category' : 'test'})
  call VUAssertTrue(pm.GetProfile('talek2@db') == {'id' : 'talek2@db', 'category' : 'test'}, 
                  \ "Is not what we expected.")

  " add a new profile into a category with the importance flag set
  call pm.StoreProfile({'id' : 'talek3@db', 'category' : 'test', 'important': '1'})
  call VUAssertTrue(pm.GetProfile('talek3@db') == {'id' : 'talek3@db', 'category' : 'test', 'important' : '1'}, 
                  \ "Ups, not good")

  " overwrite a profile
  call pm.StoreProfile({'id' : 'talek2@db', 'category' : 'new_test'})
  call VUAssertTrue(pm.GetProfile('talek2@db') == {'id' : 'talek2@db', 'category' : 'new_test'}, 
                  \ "Overwrite test.")

  " toggle the important flag
  call pm.ToggleImportant(pm.GetProfile('talek2@db'))
  call VUAssertTrue(pm.GetProfile('talek2@db') == {'id' : 'talek2@db', 'category' : 'new_test', 'important' : '1'}, 
                  \ "First important toggle.")
  call pm.ToggleImportant(pm.GetProfile('talek2@db'))
  call VUAssertTrue(pm.GetProfile('talek2@db') == {'id' : 'talek2@db', 'category' : 'new_test'}, 
                  \ "Second important toggle.")

  " test GetAll()
  call VUAssertTrue(pm.GetAll() == [{'id': 'talek@db'}, 
                                  \ {'id': 'talek2@db', 'category': 'new_test'}, 
                                  \ {'id': 'talek3@db', 'important': '1', 'category': 'test'}],
                  \ 'Test GetAll().')

  " test ToString()
  call VUAssertTrue(pm.ToString({'id' : 'a@b', 'category' : 'test', 'important' : '1', 'password' : 'abc'}) == '!a@b*', 
                  \ 'ToString() test 1')
  call VUAssertTrue(pm.ToString({'id' : 'a@b', 'password' : 'abc'}) == 'a@b*', 
                  \ 'ToString() test 2')
  call VUAssertTrue(pm.ToString({'id' : 'a@b', 'important' : '1'}) == '!a@b', 
                  \ 'ToString() test 3')

  " test GetSubNodes()
  call VUAssertTrue(pm.GetSubNodes(pm.root) == ['[new_test]', '[test]', 'talek@db'], 
                  \ 'GetSubNodes() under root')
  call VUAssertTrue(pm.GetSubNodes(pm.root . pm.path_separator . '[test]') == ['!talek3@db'], 
                  \ 'GetSubNodes() under test category')

  " test ExtractProfileNameFromCdata()
  call VUAssertTrue(pm.ExtractProfileNameFromCdata({'user' : 'u1', 'pwd' : 'xxx', 'db' : 'DB AS SYSDBA', 'osauth' : 0}) == 'u1@DB AS SYSDBA',
                  \ "Test ExtractProfileNameFromCdata 1")
  call VUAssertTrue(pm.ExtractProfileNameFromCdata({'user' : '"gigi"', 'pwd' : '"secret"', 'db' : 'POC', 'osauth' : 0}) == '"gigi"@POC',
                  \ "Test ExtractProfileNameFromCdata 2")
  call VUAssertTrue(pm.ExtractProfileNameFromCdata(voraxlib#parser#constring#Split('/ as sysdba')) == '/ as sysdba',
                  \ "Test ExtractProfileNameFromCdata 3")

  " test GetProfilePath()
  call VUAssertTrue(pm.GetProfilePath(pm.GetProfile('talek@db')) == pm.root . pm.path_separator . 'talek@db',
                  \ 'Test GetProfilePath 1')
  call VUAssertTrue(pm.GetProfilePath(pm.GetProfile('talek2@db')) == pm.root . pm.path_separator . '[new_test]' . pm.path_separator . 'talek2@db',
                  \ 'Test GetProfilePath 2')

  " test GetProfileNameFromPath
  call VUAssertTrue(pm.GetProfileNameFromPath(pm.root . pm.path_separator . '[new_test]' . pm.path_separator . 'talek2@db') == 'talek2@db',
                  \ 'Test GetProfileNameFromPath 1')
  call VUAssertTrue(pm.GetProfileNameFromPath(pm.root . pm.path_separator . 'talek@db') == 'talek@db',
                  \ 'Test GetProfileNameFromPath 2')

  " test IsCategory()
  call VUAssertTrue(!pm.IsCategory(pm.root . pm.path_separator . 'talek@db'),
                  \ 'Test IsCategory 1')
  call VUAssertTrue(pm.IsCategory(pm.root . pm.path_separator . '[new_category]'),
                  \ 'Test IsCategory 2')

  " test IsImportant
  call VUAssertTrue(pm.IsImportant(pm.root . pm.path_separator . '!talek@db'),
                  \ 'Test IsImportant 1')
  call VUAssertTrue(!pm.IsImportant(pm.root . pm.path_separator . 'talek@db'),
                  \ 'Test IsImportant 2')

  " test BuildProfileFromPath
  call VUAssertTrue(pm.BuildProfileFromPath(pm.root . 
                                          \ pm.path_separator . 
                                          \ '[new_category]' . 
                                          \ pm.path_separator . 
                                          \ '!talek@db')
                                          \ ==
                                          \ { 'id' : 'talek@db',
                                          \   'category' : 'new_category',
                                          \   'important' : '1' },
                                          \ 'Test BuildProfileFromPath 1')
  call VUAssertTrue(pm.BuildProfileFromPath(pm.root . 
                                          \ pm.path_separator . 
                                          \ 'talek@db')
                                          \ ==
                                          \ { 'id' : 'talek@db'},
                                          \ 'Test BuildProfileFromPath 2')
  
  " test GetCategory()
  call VUAssertTrue(pm.GetCategory(pm.root . pm.path_separator . '[my_cat]' . pm.path_separator . 'gigi@db') == 'my_cat',
                  \ 'Test GetCategory 1')
  call VUAssertTrue(pm.GetCategory(pm.root . pm.path_separator . 'gigi@db') == '',
                  \ 'Test GetCategory 2')

  " store a profile with password
  call pm.StoreProfile({'id' : 'talek4@db', 'category' : 'test', 'important': '1', 'password' : 'secret'})
  call VUAssertTrue(pm.GetPassword('talek4@db') == 'secret', 'Password mismatch')

  " test GetConnectionString()
  call VUAssertTrue(pm.GetConnectionString('talek4@db') == 'talek4/secret@db', 'Test GetConnectionString() 1')
  call VUAssertTrue(pm.GetConnectionString('talek3@db') == 'talek3@db', 'Test GetConnectionString() 2')

  " test RemoveProfile
  call pm.RemoveProfile(pm.GetProfile('talek4@db'))
  call VUAssertTrue(pm.GetProfile('talek4@db') == {}, 
                  \ "Test RemoveProfile")

  " dispose the profiles manager
  call pm.Destroy()
endfunction

" Remove all files from g:vorax_homedir
function! s:ClearVoraxHomeDir()
  for file_name in split(globpath(g:vorax_home_dir, '*'), "\n")
    if delete(file_name) != 0
    	echo 'Could not cleanup file ' . filename . '. The unit tests which depend on this cleanup may fail.'
    endif
  endfor
endfunction
