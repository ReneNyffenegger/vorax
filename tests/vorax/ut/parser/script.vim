function! TestVoraxParserScriptSplit()
  let stmt1 = "select * from dual;"
  let stmt2 = "select * from cat\n/\n"
  let stmt3 = "select /*+ hint with ; */, ';', '/' from dual /* comment */;"
  let stmt4 = "\nselect * from muci"
  call VUAssertEquals(voraxlib#parser#script#Split(stmt1 . stmt2 . stmt3), [stmt1, stmt2, stmt3], 'Test 1')

  call VUAssertEquals(voraxlib#parser#script#Split(''), [], 'Test empty')

  call VUAssertEquals(voraxlib#parser#script#Split(stmt3 . stmt4), [stmt3, stmt4], 'Test with last statement without separator')

  call VUAssertEquals(voraxlib#parser#script#Split(stmt4), [stmt4], 'Test with one statement without separator')
  
endfunction
