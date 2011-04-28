let win = voraxlib#widget#window#New("DbExplorer", 'v', 'topleft', 30, 0)

let tree = voraxlib#widget#tree#New(win)

function! tree.Init() dict
  " set options
  setlocal foldcolumn=0
  setlocal winfixwidth
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal nospell
  setlocal nonu
  setlocal cursorline
  setlocal noswapfile
  setlocal hid

  " set colors
  syn match Directory  '\(+\|-\).\+'
  hi link Directory  Comment

	let tree = self
	noremap <silent> <buffer> o :call tree.ClickCurrentNode()<CR>
	noremap <silent> <buffer> O :call tree.RevealNode('ROOT>n2>n22')<CR>

endfunction


function! tree.GetSubNodes(path) dict
  "echom 'Path in GetSubNodes: '.a:path
  if a:path == 'ROOT'
    return ['n1', 'n2', 'n3']
  elseif a:path == 'ROOT>n2'
    return ['n21', 'n22']
  elseif a:path == 'ROOT>n2>n22'
    return ['bing', 'bang', 'bum']
  endif
endfunction

function! tree.IsLeaf(path) dict
  "echom 'Path in isLeaf: '.a:path
  if a:path == 'ROOT>n2'
    return 0
  elseif a:path == 'ROOT>n2>n22'
    return 0
  else
  	return 1
  endif
endfunction

call tree.SetRoot('ROOT')
call tree.RevealNode('ROOT>n2>n21')
