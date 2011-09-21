" Description: Parsing utilities for a plsql source.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_parser_source") 
 finish
endif

let g:_loaded_voraxlib_parser_source = 1
let s:cpo_save = &cpo
set cpo&vim

" Split the provided script content in its corresponding sql statements.
function! voraxlib#parser#source#Describe(source_content)
  ruby VIM::command(%!return #{Vorax::VimUtils.to_vim(Orasource::Parser::describe(VIM::evaluate('a:source_content')))}!)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

