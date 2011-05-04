function! TestVoraxPanelProfiles()
  " initialize the profiles manager
  let pm = voraxlib#panel#profiles#New()
  " delete all files from test vorax home directory
  call s:ClearVoraxHomeDir()
  call VUAssertTrue(pm.IsSecureRepositoryInitialized() == 0, 'Ups, the key files should not be there.')
  " create rsa files
  call pm.CreateSecureKeys('mucimuci')
  call VUAssertTrue(findfile('id_rsa', g:vorax_home_dir) != '' && findfile('id_rsa.pub', g:vorax_home_dir) != '', 
    \ 'The CreateSecureKeys() did not create the key files.')
  call VUAssertTrue(pm.IsSecureRepositoryInitialized(), 'The secure repository should be initialized now.')
  " check if the profiles repository is unlocked
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 'The secure repository should be unlocked now.')
  " try to open with a wrong password
  call VUAssertTrue(pm.OpenMasterRepository('muci') == 0, 'The secure repository should not open with a wrong password.')
  " check if the profiles repository is unlocked
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 'After a wrong pwd, the secure repository should be locked now.')
  " open it with the good password
  call VUAssertTrue(pm.OpenMasterRepository('mucimuci') == 1, 'The secure repository should be openned now.')
  call VUAssertTrue(pm.IsSecureRepositoryUnlocked(), 'The secure repository should be unlocked now.')
  " dispose the profiles manager
  call pm.Destroy()
endfunction

" Remove all files from g:vorax_homedir
function! s:ClearVoraxHomeDir()
  for file_name in split(globpath(g:vorax_home_dir, '*'), "\n")
    call delete(file_name)
  endfor
endfunction
