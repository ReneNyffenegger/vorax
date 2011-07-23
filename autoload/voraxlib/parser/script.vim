" Description: Parsing utilities for an sql script.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_parser_script") 
 finish
endif

let g:_loaded_voraxlib_parser_script = 1
let s:cpo_save = &cpo
set cpo&vim

" Split the provided script content in its corresponding sql statements.
function! voraxlib#parser#script#Split(script_content)
  ruby VIM::command(%!return #{Vorax::VimUtils.to_vim(SqlSplitter::Lexer::split(VIM::evaluate('a:script_content')))}!)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
