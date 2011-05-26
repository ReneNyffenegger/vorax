" Description: Parsing utilities for sqlplus html output.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

" Convert the provided html output to text.
function voraxlib#parser#output#Compress(html)
  let sqlplus = vorax#GetSqlplusHandler()
  if !sqlplus.IsBusy()
    let params = sqlplus.GetConfigFor(['colsep', 'recsep', 'recsepchar', 'underline'])
    " extract the column separator
    let colsep = matchstr(params[0], '"\@<=[^"]\+')
    " extract the record separator
    if params[1] =~? '\<EACH\>'
      let recsep = 1
    else
    	let recsep = 0
    endif
    " extract the record separator character
    let recsepchar = matchstr(params[2], '"\@<=[^"]\+')
    " extract underline
    if params[3] =~? '\<OFF\>'
      let underline = ''
    else
      let underline = matchstr(params[3], '"\@<=[^"]\+')
    endif
    echom 'colsep='.colsep.' recsep='.recsep.' recsepchar='.recsepchar.' underline='.underline
  endif
  ruby <<EORC
    vorax_html = Vorax::SqlHtmlBeautifier.new()
    # register default handlers
    vorax_html.register_tag_handler(Vorax::TextTagHandler.new)
    vorax_html.register_tag_handler(Vorax::PTagHandler.new)
    if VIM::evaluate('exists("params")') == 1
      vorax_html.register_tag_handler(Vorax::TableTagHandler.new(VIM::evaluate('colsep'), VIM::evaluate('underline'), (VIM::evaluate('recsep')==1 ? true : false), VIM::evaluate('recsepchar')))
    else
      vorax_html.register_tag_handler(Vorax::TableTagHandler.new)
    end
    VIM::command("return #{vorax_html.beautify(VIM::evaluate('a:html')).inspect}")
EORC
endfunction
