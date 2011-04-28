" Description: Implements a rude simplistic throbber.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo = &cpo
set cpo-=C

let s:throbber = {
      \ 'chars' : ['|', '/', '-', '*', '\'],
      \ 'index' : -1,
      \ }

" Creates a new throbber object.
function! voraxlib#widget#throbber#New(...)
  let t = copy(s:throbber)
  if a:0 > 0
    let t.chars = voraxlib#utils#FlattenList(a:000)
  endif
  return t
endfunction

" Spins and returns the new format of
" the throbber.
function! s:throbber.Spin()
  if len(self.chars) > 0
    if self.index < len(self.chars) - 1
      let self.index += 1
    else
      let self.index = 0
    endif
    return self.chars[self.index]
  endif
endfunction

let &cpo=s:cpo
unlet s:cpo
