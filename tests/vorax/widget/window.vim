let s:cpo_save=&cpo
set cpo&vim

UTSuite [voraxlib#widget#window] Testing the window widget

" Test for invalid chars in the window name
try
  call voraxlib#widget#window#New("Muci_", "v", "topleft", 30, 1)
  Assert 0 
catch /^Invalid window name/
endtry

" Test for valid split types
try
  call voraxlib#widget#window#New("Muci", "a", "topleft", 30, 1)
  Assert 0 
catch /^Invalid split type/
endtry

" Test for valid orientatons
try
  call voraxlib#widget#window#New("Muci", "h", "muci", 30, 1)
  Assert 0 
catch /^Invalid orientation/
endtry

let &cpo=s:cpo_save
