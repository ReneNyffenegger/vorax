" Purpose:  Vim syntax file
" Language: Voraxoutput
" Author:   Alexandru Tica

if !exists('b:current_syntax')
  exe 'syn match ' . g:vorax_output_window_column_underline_hi_group . ' /^\(-\+\s*\)\+$/'
  exe 'syn match ' . g:vorax_output_window_feedback_hi_group . ' /^\(\d\+ rows selected\.\)\|\(\w\+ \(body \|view \|link \)\?\(created\|altered\|dropped\|purged\)\.\)\|\(PL\/SQL procedure successfully completed\.\)$/'
  exe 'syn match ' . g:vorax_output_window_error_hi_group . ' /^Warning: .*\.$/'
  exe 'syn match ' . g:vorax_output_window_error_hi_group . ' /^\(ORA\|SP[0-9]\?\|PLS\)-[0-9]\+.*$/'
  exe 'syn match ' . g:vorax_output_window_feedback_hi_group . ' /^\*\*\* output may be truncated \*\*\*$/'
endif

let b:current_syntax = "voraxoutput"

