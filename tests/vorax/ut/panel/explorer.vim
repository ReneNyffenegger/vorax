function! TestVoraxPanelExplorerDescribeNode()
  let explorer = vorax#GetExplorerHandler()
  call vorax#GetSqlplusHandler().Exec('connect ' . g:vorax_test_constr)
  let result = vorax#GetSqlplusHandler().Query('select sys_context(''USERENV'', ''SESSION_USER'') crr_user from dual;')
  let owner = get(get(result.resultset, 0), 'CRR_USER')

  let path = join(['@', '[Users]', '[MUCI]'], explorer.path_separator)
  call VUAssertEquals(explorer.DescribePath(path), {'owner' : 'MUCI', 'object' : '', 'type' : ''})

  let path = join(['@', '[Users]', '[MUCI]', '[Packages]'], explorer.path_separator)
  call VUAssertEquals(explorer.DescribePath(path), {'owner' : 'MUCI', 'object' : '', 'type' : 'PACKAGE'})

  let path = join(['@', '[Users]', '[MUCI]', '[Packages]', 'MY_PKG'], explorer.path_separator)
  call VUAssertEquals(explorer.DescribePath(path), {'owner' : 'MUCI', 'object' : 'MY_PKG', 'type' : 'PACKAGE'})

  let path = join(['@', '[Functions]', 'MY_FUNC'], explorer.path_separator)
  call VUAssertEquals(explorer.DescribePath(path), {'owner' : owner, 'object' : 'MY_FUNC', 'type' : 'FUNCTION'})
endfunction
