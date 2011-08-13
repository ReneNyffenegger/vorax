" Purpose:  Vim syntax file
" Language: Voraxoutput
" Author:   Alexandru Tica

syn match Error /^\(-\+\s*\)\+$/
syn match Directory /^\(\d\+ rows selected\.\)\|\(\w\+ \(body \|view \)\?created\.\)\|\(PL\/SQL procedure successfully completed\.\)$/
syn match ErrorMsg /^Warning: .*\.$/

let b:current_syntax = "voraxoutput"

