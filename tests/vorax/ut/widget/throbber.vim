function! TestVoraxWidgetThrobberDefault()
  let t = voraxlib#widget#throbber#New()
  " test default throbber spinning
  for c in t.chars 
    call VUAssertEquals(c, t.Spin())
  endfor
endfunction

function! TestVoraxWidgetThrobberEmpty()
  let t = voraxlib#widget#throbber#New()
  " test empty throbber
  let t.chars = []
  call VUAssertEquals(t.Spin(), '')
endfunction

function! TestVoraxWidgetThrobberCustom()
  " test with custom throbber glyphs
  let t = voraxlib#widget#throbber#New('-', '|', '+', '*')
  for c in ['-', '|', '+', '*']
    call VUAssertEquals(c, t.Spin())
  endfor
endfunction
