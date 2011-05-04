function! TestVoraxWidgetWindow()
  " Test for invalid chars in the window name
  try
    call voraxlib#widget#window#New("Muci_#", "v", "topleft", 30, 1)
    call VUAssertFail('The window name is invalid.')
  catch /^Invalid window name/
  endtry
  " Test for valid split types
  try
    call voraxlib#widget#window#New("Muci", "a", "topleft", 30, 1)
    call VUAssertFail('The window orientation is invalid.')
  catch /^Invalid orientation/
  endtry

  " Test for valid orientatons
  try
    call voraxlib#widget#window#New("Muci", "h", "muci", 30, 1)
    call VUAssertFail('The window anchor is invalid.')
  catch /^Invalid anchor/
  endtry
endfunction


