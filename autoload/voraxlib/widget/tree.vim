" Description: Provides an abstraction for a basic tree widget. Many
" implementation ideas comes from Yury Altukhou tree plugin:
" http://www.vim.org/scripts/script.php?script_id=1139
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo = &cpo
set cpo-=C

let s:tree = {
      \ 'window' : {},
      \ 'root' : '',
      \ 'path_separator' : '>', 
      \ 'expanded_nodes' : [],
      \}

" *** PUBLIC INTERFACE ***

" Creates a new tree widget. It expects a voraxlib#widget#window as a
" container and the root path of the tree.
function! voraxlib#widget#tree#New(window)"{{{
  let tree = copy(s:tree)
  let tree.window = a:window
  return tree
endfunction"}}}

" Comparator function to sort taking into account the depth of the tree.
function voraxlib#widget#tree#DepthSort(i1, i2)"{{{
  let d1 = len(split(a:i1, voraxlib#utils#LiteralRegexp(s:tree.path_separator)))
  let d2 = len(split(a:i2, voraxlib#utils#LiteralRegexp(s:tree.path_separator)))
  return d1 == d2 ? 0 : d1 > d2 ? 1 : -1
endfunction"}}}

" Set the root of the tree. This also triggers the building of the tree
" starting from the provided root.
function! s:tree.SetRoot(root) dict"{{{
  let self.root = a:root
  call self.window.Focus()
  setlocal nowrap
  call s:BuildTree(self)
  normal gg
endfunction"}}}

" Get the children nodes for the provided path. This is intended to be
" overridden by the implementors.
function! s:tree.GetSubNodes(path) dict"{{{
  return []
endfunction"}}}

" Whenever or not the node identified by the given path is a leaf. This is
" intended to be overridden by implementors.
function! s:tree.IsLeaf(path) dict"{{{
  return 1
endfunction"}}}

" What to do when a leaf node is clicked. This is intended to be overridden by
" implementors.
function! s:tree.OnLeafClick(path) dict"{{{
endfunction"}}}

" Click on the current node.
function! s:tree.ClickNode(path)"{{{
  call self.RevealNode(a:path)
  normal ^
  let xpos = col('.') - 1
  let ypos = line('.')
  let path = s:GetPathName(xpos, ypos, self)
  if self.IsLeaf(path)
  	call self.OnLeafClick(path)
  else
    " expand/colapse the node
    if getline(ypos) =~ '\m^\s*+'
      call s:TreeExpand(xpos, ypos, self)
    elseif getline(ypos) =~ '\m^\s*-'
      call s:TreeCollapse(xpos, ypos, self)
    endif
  endif
endfunction"}}}

" Get the path to the current node.
function! s:tree.GetCurrentNode() dict"{{{
  let crr_pos = getpos(".")
  normal ^
  let xpos = col('.') - 1
  let ypos = line('.')
  let path = s:GetPathName(xpos, ypos, self)
  call setpos('.', crr_pos) 
  return path
endfunction"}}}

" Expand the current node.
function! s:tree.ExpandCurrentNode() dict "{{{
  let crr_pos = getpos(".")
  normal ^
  let xpos = col('.') - 1
  let ypos = line('.')
  call s:TreeExpand(xpos, ypos, self)
  call setpos('.', crr_pos) 
endfunction"}}}

" Collapse the current node.
function! s:tree.CollapseCurrentNode() dict "{{{
  let crr_pos = getpos(".")
  normal ^
  let xpos = col('.') - 1
  let ypos = line('.')
  call s:TreeCollapse(xpos, ypos, self)
  call setpos('.', crr_pos) 
endfunction"}}}

" Show and selects the provided node
function! s:tree.RevealNode(path) dict"{{{
  " split the provided path
  let parts = split(a:path, self.path_separator)
  normal gg
  let ypos = 1
  let indent = 0
  let index = 1
  " loop through all path components.
  for part in parts
    " scan tree buffer
    let found = 0
    while ypos <= line('$')
      let line = getline(ypos)
      if index == 1 && line == part
        " that's the root node
        let found = 1
        break
      elseif index > 1 && line =~ '\m^\s\{' . indent . '\}[+ -]' . voraxlib#utils#LiteralRegexp(part)
        " If it's not the last part from the path and it's collapsed
        if index < len(parts) && line =~ '\m^\s\{' . indent . '\}[+]'
          " the node is collapsed therefore it have to be expanded in order to
          " find it's children
          exe 'normal ' . ypos . 'G'
          call self.ExpandCurrentNode()
        endif
        let found = 1
        break
      endif
      let ypos += 1
    endwhile
    if !found 
      return
    else
      let ypos += 1
      let index += 1
      if index > 2
      	let indent += 1
      endif
    endif
  endfor
  exe 'normal' . (ypos - 1) . 'G'
endfunction!"}}}

" *** INTERNAL FUNCTONS ***"{{{

" build the provided tree
function! s:BuildTree(tree) "{{{
	let path = a:tree.root
	" unlock bufer
	call a:tree.window.UnlockBuffer()
	" clean up
	normal ggdGd
	call setline(1,path)
	call a:tree.window.LockBuffer()
	call s:TreeExpand(-1, 1, a:tree)
	" move to first entry
	norm ggj1|g^
  if len(a:tree.expanded_nodes) > 0
  	call s:RestoreState(a:tree)
  endif
endfunction "}}}

" restore the previous tree open folders state.
function! s:RestoreState(tree)"{{{
  " check if the nodes from the expanded_nodes are still valid
  let to_be_deleted = []
  for node in a:tree.expanded_nodes
    if len(a:tree.GetSubNodes(node)) == 0
      call add(to_be_deleted, node)
    endif
  endfor
  for node in to_be_deleted
    call remove(a:tree.expanded_nodes, index(a:tree.expanded_nodes, node))
  endfor
  " sort expanded list by depth
  let expanded_list = sort(a:tree.expanded_nodes, "voraxlib#widget#tree#DepthSort")
  for node in expanded_list
    call a:tree.RevealNode(node)
    call a:tree.ExpandCurrentNode()
  endfor
endfunction"}}}

" expand a node from the provided tree at the xpos/ypos position. The node is
" the actual path to it.
function! s:TreeExpand (xpos, ypos, tree) "{{{
	let node = s:GetPathName(a:xpos, a:ypos, a:tree)
	" first get all subdirectories
	let nodelist = a:tree.GetSubNodes(node)
	call s:AppendSubNodes(a:xpos, a:ypos, a:tree, nodelist)
  if node != a:tree.root
    call voraxlib#utils#AddUnique(a:tree.expanded_nodes, node)
  endif
endfunction "}}}

" collapse the node on the xpos/ypos position from the provided tree.
function! s:TreeCollapse (xpos, ypos, tree) "{{{
	call a:tree.window.UnlockBuffer()
	" turn - into +, go to next line
	let path = s:GetPathName(a:xpos, a:ypos, a:tree) 
	if a:tree.IsLeaf(path)
		normal ^r j
	else
		normal ^r+j
	end
	" delete lines til next line with same indent
	while (getline ('.')[a:xpos+1] =~ '[ +-]') && (line ('$') != line ('.')) 
		norm dd
	endwhile 
	" go up again
	normal k
	call a:tree.window.LockBuffer()
  call remove(a:tree.expanded_nodes, index(a:tree.expanded_nodes, path))
endfunction "}}}

" add the provided nodeList within the given tree at the xpos/ypos location.
function! s:AppendSubNodes(xpos, ypos, tree, nodeList) "{{{
	call a:tree.window.UnlockBuffer()
	" turn + into -
	if a:ypos != 1 
		if getline(a:ypos)[a:xpos] == '+'  
			normal r-
		else
			normal hxi-
		endif 
	endif 
	let nodeList = a:nodeList
	let row = a:ypos
	let prefix = s:GetPathName(a:xpos, a:ypos, a:tree)
	for node in nodeList
		" add to tree 
		if node != "" 
			let path = prefix . a:tree.path_separator . node
			if a:tree.IsLeaf(path)
				let node = s:SpaceString(a:xpos + 2) . node
			else
				let node = s:SpaceString(a:xpos + 1) . "+" . node
			endif 
			call append(row, node)
			let row = row + 1
		endif 
	endfor
	call a:tree.window.LockBuffer()
endfunction "}}}

" return a string with a number of blanks given by the width argument.
function! s:SpaceString (width) "{{{
	let spacer=""
	let width=a:width
	while width>0
		let spacer=spacer." "
		let width=width-1
	endwhile
	return spacer
endfunction "}}}

" given the xpos/ypos location within the provided tree computes and return
" the corresponding path to that node.
function! s:GetPathName(xpos, ypos, tree) "{{{
	let xpos = a:xpos
	let ypos = a:ypos
	" check for expandable node
	if getline(ypos)[xpos] =~ "[+-]" 
		let path = (a:tree.path_separator) . strpart(getline(ypos), xpos + 1, col('$'))
	else
		" otherwise filename
		let path = (a:tree.path_separator) . strpart(getline(ypos), xpos, col('$'))
		let xpos = xpos - 1
	end 
	" walk up tree and append subpaths
	let row = ypos - 1
	let indent = xpos
	while indent > 0 
		" look for prev ident level
		let indent = indent - 1
		while getline(row)[indent] != '-' 
			let row = row - 1
			if row == 0 
				return ""
			end 
		endwhile 
		" subpath found, append
		let path = (a:tree.path_separator) . strpart(getline(row), indent + 1, strlen(getline(row))) . path
	endwhile  
	" finally add base path
	" not needed, if in root
	if a:ypos > 1 
		let path = getline(1) . path
	end 
	" remove the first separator, if any
	if strpart(path, 0, strlen(a:tree.path_separator)) == a:tree.path_separator
    let path = strpart(path, strlen(a:tree.path_separator), len(path))
  endif
	return path
endfunction "}}}
"}}}

let &cpo=s:cpo
unlet s:cpo

