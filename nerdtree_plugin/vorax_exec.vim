" Description: Executes the sqlplus file from the NERDTree.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if exists("g:vorax_nerdtree_exec")
    finish
endif
let g:vorax_nerdtree_exec = 1 

" Add ! key to execute a node in vorax.
call NERDTreeAddKeyMap({'key': '@', 'quickhelpText': 'Execute file under VoraX.', 'callback': 'NERDTreeVoraxExec'})

" Callback function to actually execute the vorax file.
function! NERDTreeVoraxExec()
  let treenode = g:NERDTreeFileNode.GetSelected()
  if !treenode.path.isDirectory
    let cmd = treenode.path.str({'escape': 0})
    " to address blanks in path on windows
    let cmd = fnamemodify(cmd, ':8')
      if voraxlib#utils#IsVoraxManagedFile(cmd)
        " The interface object
        let sqlplus = vorax#GetSqlplusHandler()
        call vorax#Exec('@' . sqlplus.ConvertPath(cmd))
      else
        call voraxlib#utils#Warn('Not a VoraX managed file.')
      endif
  endif
endfunction 

