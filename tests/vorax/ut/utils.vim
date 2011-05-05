" Tests for voraxlib#utils.vim
function! TestVoraxUtils()
  " test sorts
  call VUAssertTrue(voraxlib#utils#SortUnique([3, 3, 1, 2]) == ['1', '2', '3'], 'Test SortUnique() 1')
  call VUAssertTrue(voraxlib#utils#SortUnique(['a', 'b', 'a', 'd', 'd', 'c']) == ['a', 'b', 'c', 'd'], 'Test SortUnique() 2')
  
  " test FlattenList
  call VUAssertTrue(voraxlib#utils#FlattenList([1, 2, [3, [4, 5], 7], 8]) == [1, 2, 3, 4, 5, 7, 8], 'Test FlattenList() 1')
  call VUAssertTrue(voraxlib#utils#FlattenList([1, [1, 1], 2]) == [1, 1, 1, 2], 'Test FlattenList() 2')

  " test AddUnique
  let list = [1, 2, 3]
  call voraxlib#utils#AddUnique(list, 1)
  call VUAssertTrue(list == [1, 2, 3], 'Test AddUnique() 1')
  call voraxlib#utils#AddUnique(list, 4)
  call VUAssertTrue(list == [1, 2, 3, 4], 'Test AddUnique() 2')
endfunction


