" Purpose:  Vim syntax file
" Language: Voraxoutput
" Author:   Alexandru Tica

if !exists('b:current_syntax')
  syn match Error /^\(-\+\s*\)\+$/
  syn match Directory /^\(\d\+ rows selected\.\)\|\(\w\+ \(body \|view \)\?\(created\|altered\|dropped\)\.\)\|\(PL\/SQL procedure successfully completed\.\)$/
  syn match ErrorMsg /^Warning: .*\.$/
  syn match ErrorMsg /^\(ORA\|SP[0-9]\?\|PLS\)-[0-9]\+.*$/
endif

let b:current_syntax = "voraxoutput"

