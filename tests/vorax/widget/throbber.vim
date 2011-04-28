let s:cpo_save=&cpo
set cpo&vim

UTSuite [voraxlib#widget#throbber] Testing the throbber widget

let t = voraxlib#widget#throbber#New()

" test default throbber spinning
for c in t.chars 
  Assert c == t.Spin()
endfor

" test empty throbber
let t.chars = []
Assert t.Spin() == ''

unlet t

" test with custom throbber glyphs
let t = voraxlib#widget#throbber#New('-', '|', '+', '*')
for c in ['-', '|', '+', '*']
  Assert c == t.Spin()
endfor
unlet t

let &cpo=s:cpo_save
