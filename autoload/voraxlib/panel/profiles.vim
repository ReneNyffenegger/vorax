" Description: Implements the VoraX connection profiles panel/window. This is
" a window with a tree where the user may add their most frequently used
" connection strings grouping them by category.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

if &cp || exists("g:_loaded_voraxlib_panel_profiles") 
 finish
endif

let g:_loaded_voraxlib_panel_profiles = 1
let s:cpo_save = &cpo
set cpo&vim

if exists('s:initialized') | unlet s:initialized | endif

" The profiles window instance.
let s:profiles = {}

" Internal flag used to force a connection window refresh.
let s:must_refresh = 0

" Creates a new connection profiles window. Only one such window
" is allowed in a VoraX instance. 
function! voraxlib#panel#profiles#New()"{{{
  if !exists('s:initialized')
    " Create the container window for the profiles tree.
    let win = voraxlib#widget#window#New('__VoraxProfiles__', 
          \ g:vorax_profiles_window_orientation,
          \ g:vorax_profiles_window_anchor, 
          \ g:vorax_profiles_window_size,
          \ 0)
    " No profile tree has been initialized. Create it now.
    let s:profiles = voraxlib#widget#tree#New(win) 
    " Rules for checking the input for a profile name.
    let s:profile_name_checker = { 'prompt' : 'Connection String: ', 
                                \  'check' : [
                                              \ {'regexp' : '[a-zA-Z]\+',
                                              \  'errmsg' : 'Please specify a valid profile name.'},
                                              \ {'regexp' : '[^\]]$', 
                                              \  'errmsg' : 'The last "]" char is not valid for a profile name.'},
                                              \ {'regexp' : '^[^!]', 
                                              \  'errmsg' : 'The first "!" char is not valid for a profile name.'},
                                              \ {'regexp' : '[^\*]$', 
                                              \  'errmsg' : 'The last "*" char is not valid for a profile name.'},
                                              \ {'regexp' : '^[^' . voraxlib#utils#LiteralRegexp(s:profiles.path_separator) . ']*$', 
                                              \  'errmsg' : (s:profiles.path_separator) . ' char is not valid for a profile name.'},
                                              \ ]
                                \ }
    " link to the ruby ProfilesManager facility
    ruby $vorax_profiles = Vorax::ProfilesManager.new(VIM::evaluate('g:vorax_home_dir'))
    " Add additional methods to the s:profiles object.
    call s:ExtendProfiles()
    let s:initialized = 1
  endif
  return s:profiles
endfunction"}}}

" Provides completion for profile categories.
function! voraxlib#panel#profiles#CategoriesList(arglead, cmdline, cursorpos)"{{{
  let profiles = s:profiles.GetAll()
  let categories =  voraxlib#utils#SortUnique(
        \ map(filter(copy(profiles), 
              \ 'has_key(v:val, "category") && v:val.category =~ ''^'' . a:arglead'), 
              \ 'v:val.category'))
  return categories
endfunction"}}}

" Provides completion for profile names. It is used in the VoraxConnect
" command.
function! voraxlib#panel#profiles#ProfilesForCompletion(arglead, cmdline, cursorpos)"{{{
  let profiles = vorax#GetProfilesHandler().GetAll()
  let profile_names =  voraxlib#utils#SortUnique(
        \ map(filter(copy(profiles), 
              \ 'has_key(v:val, "id") && v:val.id =~ ''^'' . a:arglead'), 
              \ 'v:val.id'))
  return profile_names
endfunction"}}}

" Add additional methods.
function! s:ExtendProfiles()"{{{

  " Get children profiles for the provided path.
  function! s:profiles.GetSubNodes(path) dict"{{{
    let profiles = self.GetAll()
    if a:path == self.root
      " profiles under root
      let simple_profiles =  map(filter(copy(profiles), '!has_key(v:val, "category") || v:val.category == ""'), 
                                \ 'self.ToString(v:val)')
      let categories =  map(filter(copy(profiles), 'has_key(v:val, "category") && v:val.category != ""'), 
                          \ '"[".(v:val.category)."]"')
      return voraxlib#utils#SortUnique(extend(simple_profiles, categories))
    elseif self.IsCategory(a:path)
      " profiles under a category
      let category = self.GetCategory(a:path)
      return voraxlib#utils#SortUnique(map(filter(copy(profiles), 
            \ 'has_key(v:val, "category") && v:val.category == "' . escape(category, '"') . '"'), 
            \ 'self.ToString(v:val)'))
    endif
  endfunction"}}}

  " Whenever or not the node is a leaf one.
  function! s:profiles.IsLeaf(path) dict"{{{
    if self.IsCategory(a:path)
      " if ends with a ']' then it's a category.
      return 0
    else
      return 1
    endif
  endfunction"}}}

  " Initialize the tree window.
  function! s:profiles.window.Configure() dict"{{{
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
    syn match VoraxProfileFlag #!#
    syn match Directory  '^\s*\(+\|-\).\+'
    syn match SpecialKey  '\*$'
    syn match Error  '\(^\s*!\)\@<=.\+'
    hi link Directory  Comment
    hi def link VoraxProfileFlag ignore

    " set key mappings
    noremap <silent> <buffer> o :call <SID>Click()<CR>
    noremap <silent> <buffer> <CR> :call <SID>Click()<CR>
    exe "noremap <silent> <buffer> " . g:vorax_profiles_window_menu_key . " :call <SID>InvokeMenu()<CR>"
    noremap <silent> <buffer> ! :call <SID>ToggleImportantCurrentNode()<CR>
  endfunction"}}}

  " What to do when a profile node is clicked.
  function! s:profiles.OnLeafClick(path)"{{{
    let profile_name = self.GetProfileNameFromPath(a:path) 
    call vorax#Connect(self.GetConnectionString(profile_name), '!')
  endfunction"}}}

  " Convert a profile into its string representation. This is used to actually
  " represent/show the profile within the profiles window tree.
  function! s:profiles.ToString(profile)"{{{
      return (has_key(a:profile, "important") && a:profile.important == "1" ? "!" : "") 
            \ . (a:profile.id)
            \ . (has_key(a:profile, "password") ? "*": "")
  endfunction"}}}

  " Toggle the profiles window.
  function! s:profiles.Toggle() dict"{{{
    if self.root == ''
      call self.SetRoot('CONNECTION PROFILES')
    else
    	call self.window.Toggle()
    endif
  endfunction"}}}

  " Gets all profiles from profiles.xml config file.
  function! s:profiles.GetAll() dict"{{{
    ruby <<EORC
      profiles = []
      $vorax_profiles.repository_xml.root.elements.each do |profile|
        profiles << profile.attributes
      end
      VIM::command(%!return #{Vorax::VimUtils.to_vim(profiles)}!)
EORC
  endfunction"}}}

  " Given a cdata parsing structure extracts and returns the corresponding
  " profile name.
  function! s:profiles.ExtractProfileNameFromCdata(cdata)"{{{
    let profile = a:cdata['user']
    if !a:cdata['osauth']
      let profile .= "@" . a:cdata['db']
    endif
    return profile
  endfunction"}}}

  " Get the password for the provided profile.
  function! s:profiles.GetPassword(profile_name)"{{{
    if !s:profiles.IsSecureRepositoryUnlocked()
      if !s:AskForMasterPassword()
        return ''
      endif
    endif
    ruby <<EORC
    begin
      VIM::command(%!return #{$vorax_profiles.password(VIM::evaluate('a:profile_name')).inspect}!)
    rescue OpenSSL::PKey::RSAError
      VIM::command('call voraxlib#utils#Warn("Cannot get the stored password for this profile using the current master password.")')
    end
EORC
  endfunction"}}}

  " Get the connection string for the provided profile
  function! s:profiles.GetConnectionString(profile_name)"{{{
    let profile = self.GetProfile(a:profile_name)
    if has_key(profile, 'id')
      " a profile was found
      let cdata = voraxlib#parser#constring#Split(profile.id)
      if has_key(profile, 'password')
        let cdata['passwd'] = self.GetPassword(a:profile_name)
      endif
      return voraxlib#connection#CdataToCstr(cdata)
    else
    	" no profile was found
    	return ''
    endif
  endfunction"}}}

  " Whenever or not the master repository was initialized.
  function! s:profiles.IsSecureRepositoryInitialized()"{{{
    ruby <<EORC
    if Vorax::ProfilesManager.initialized?(VIM::evaluate('g:vorax_home_dir'))
    	VIM::command('return 1')
    else
    	VIM::command('return 0')
    end
EORC
  endfunction"}}}

  " Add a new profile
  function! s:profiles.Add(cstr, attributes) dict"{{{
    let cstr = a:cstr
    let password = ''
    let category = ''
    if cstr == ''
      " No connection string was provided. Ask the user.
      let cstr = voraxlib#utils#Ask(s:profile_name_checker)
      if cstr == ''
      	echo 'Aborted!'
      	return
      endif
    endif
    " parse the connection string
    let cdata = voraxlib#parser#constring#Split(cstr)
    " prepare password
    let password = s:PreparePassword(cdata['passwd'])
    " compute the profile name based on the provided connection string
    let profile_name = self.ExtractProfileNameFromCdata(cdata)
    " If no category was provided
    if !has_key(a:attributes, 'category')
      " Ask the user for a category
      let category = s:PromptForCategory()
    else
      let category = a:attributes['category']
    endif
    let profile = {'id' : profile_name, 'password' : password, 'category' : category}
    " Save profile
    call self.StoreProfile(profile)
    " Refresh/update connection profiles window
    call self.RefreshProfile(profile)
  endfunction"}}}

  " Store the provided profile, with the corresponding password and category.
  " Empty password='' means no password and empty category='' means no
  " category. The profile must have the following structure:
  " {'id':'', 'password':'', 'category':''}
  function! s:profiles.StoreProfile(profile)"{{{
    ruby <<EORC
    profile_name = VIM::evaluate('a:profile.id') 
    category = (VIM::evaluate('has_key(a:profile, "category")') == 1 && VIM::evaluate("a:profile.category") != '' ? VIM::evaluate('a:profile.category') : nil)
    password = (VIM::evaluate('has_key(a:profile, "password")') == 1 && VIM::evaluate('a:profile.password') != '' ? VIM::evaluate('a:profile.password') : nil)
    important = (VIM::evaluate('has_key(a:profile, "important")') == 1 && VIM::evaluate('a:profile.important') != '' ? VIM::evaluate('a:profile.important') : nil)
    $vorax_profiles.add(profile_name, 
                        password, 
                        {:category => category, :important => important})
    $vorax_profiles.save
EORC
  endfunction"}}}

  " Create the secure keys based on the provided master password.
  function! s:profiles.CreateSecureKeys(master_password)"{{{
    ruby Vorax::ProfilesManager.create(VIM::evaluate('g:vorax_home_dir'), VIM::evaluate('a:master_password'))
    ruby $vorax_profiles.master_password = VIM::evaluate('a:master_password')
  endfunction"}}}

  " Opens up the master repository using the provided master password. It
  " returns 1 if the open was successfull and 0 otherwise.
  function! s:profiles.OpenMasterRepository(master_password)"{{{
    ruby <<EORC
    begin
      $vorax_profiles.master_password=VIM::evaluate('a:master_password')
      VIM::command('return 1')
    rescue OpenSSL::PKey::RSAError
      VIM::command('return 0')
    rescue => e
      puts e.message
      VIM::command('return 0')
    end
EORC
  endfunction"}}}

  " Whenever or not the secure repository is unlocked. The repository is
  " unlocked after a valid master password was provided.
  function! s:profiles.IsSecureRepositoryUnlocked()"{{{
    ruby <<EORC
    if $vorax_profiles.unlocked
    	VIM::command('return 1')
    else
    	VIM::command('return 0')
    end
EORC
  endfunction"}}}

  " Toggle the importantness of the given profile.
  function! s:profiles.ToggleImportant(profile)"{{{
    let profile = a:profile
    if has_key(profile, 'important')
    	" already important. remove flag.
      call remove(profile, 'important')
    else
      " currently no important. set flag as important.
      let profile['important'] = '1'
    endif
    ruby <<EORC
    if p = $vorax_profiles.exists?(VIM::evaluate('profile.id'))
    	p.add_attribute('important', (VIM::evaluate('has_key(profile, "important")') == 1 && VIM::evaluate('profile.important') == '1' ? '1' : nil))
      $vorax_profiles.save
    end
EORC
  endfunction"}}}

  " Given a profile it computes the path into the connection window tree. The
  " profile is a dictionary with the following structure:
  " {'id':'', 'password':'', 'category':''}
  function! s:profiles.GetProfilePath(profile)"{{{
    let profile_name = a:profile.id
    let category = ''
    if has_key(a:profile, 'category') && a:profile.category != ''
      let category = a:profile['category']
    endif
    if has_key(a:profile, 'password') && a:profile.password != ''
      let profile_name .= '*'
    endif
    if has_key(a:profile, 'important') && a:profile.important == '1'
      let profile_name = '!' . profile_name
    endif
    return (self.root) . (self.path_separator)
          \ . (category != '' ? '[' . category . ']' . (self.path_separator) : '') 
          \ . profile_name
  endfunction"}}}

  " Given a profile path extracts and returns the profile name.
  function! s:profiles.GetProfileNameFromPath(path)"{{{
    let parts = split(a:path, self.path_separator)
    let id = ''
    if len(parts) > 0
      " get rid of the important and pwd markers
      let id = substitute(parts[len(parts)-1], '^!\|\*$', '', 'g')
    endif
    return id
  endfunction"}}}

  " Whenever or not the provided node refers to a category.
  function! s:profiles.IsCategory(node)"{{{
   return a:node =~ ']$'
  endfunction"}}}

  " Given a node path in tree it builds a corresponding profile structure.
  function! s:profiles.BuildProfileFromPath(path)"{{{
    let id = self.GetProfileNameFromPath(a:path)
    let profile = { 'id' : id }
    let category = self.GetCategory(a:path)
    if category != ''
      let profile['category'] = category
    endif
    if self.IsImportant(a:path)
      let profile['important'] = '1'
    endif
    return profile
  endfunction"}}}

  " Whenever or not the provided path leads to an important profile.
  function! s:profiles.IsImportant(path)"{{{
    return a:path =~ voraxlib#utils#LiteralRegexp(self.path_separator) . '!'
  endfunction"}}}

  " Get the profile object corresponding to the provided name/id.
  function! s:profiles.GetProfile(profile_name)"{{{
    ruby <<EORC
    if p = $vorax_profiles.exists?(VIM::evaluate('a:profile_name'))
      VIM::command(%!return #{Vorax::VimUtils.to_vim(p.attributes)}!)
    else
    	VIM::command('return {}')
    end
EORC
  endfunction"}}}

  " Refresh the provided profile (along with its attributes) into the 
  " profiles window.
  function! s:profiles.RefreshProfile(profile)"{{{
    if self.window.IsOpen()
      call self.SetRoot(self.root)
      call self.RevealNode(self.GetProfilePath(a:profile))
    else
      " force a full refresh on the next toggle
      let s:must_refresh = 1
    endif
    redraw
  endfunction"}}}

  " Get the category for the provided node. If no category is found then an
  " empty string is returned.
  function! s:profiles.GetCategory(node)"{{{
    return substitute(matchstr(a:node, '\[.\+\]'), '\[\|\]', '', 'g') 
  endfunction"}}}

  " Remove the provided profile.
  function! s:profiles.RemoveProfile(profile)"{{{
    let profile_name = a:profile.id
    ruby $vorax_profiles.remove(VIM::evaluate('profile_name'))
    ruby $vorax_profiles.save
    let category = ''
    if self.window.IsOpen()
      " refresh tree
      call self.SetRoot(self.root)
      if has_key(a:profile, 'category')
        let category = a:profile.category
        let category_node = (self.root) . (self.path_separator) . '[' . category . ']'
        let remaining = self.GetSubNodes(category_node)
        if len(remaining) > 0
          call self.RevealNode(self.GetProfilePath({'id' : remaining[0], 'category' : category}))
        endif
      endif
      redraw
    else
    	let s:must_refresh = 1
    endif
  endfunction"}}}

  " Disposes the profiles manager.
  function! s:profiles.Destroy()"{{{
    call self.window.Close()
    unlet s:initialized
    ruby $vorax_profiles = nil
  endfunction"}}}
  
endfunction"}}}

" Prepare the secure repository for passwords management. It receives the
" password of the profile and it returns the same password if the repository
" is ready for managing it or '' otherwise.
function! s:PreparePassword(pwd)"{{{
  let password = ''
  if a:pwd != '' 
    if !s:profiles.IsSecureRepositoryInitialized()
      " the password was provided and the repository was not initialized
      if s:PromptForCreateSecureKeys()
        " if here the master repository keys are created.
        let password = a:pwd
      endif
    else
      " the password was provided and the master keys are already created.
      if !s:profiles.IsSecureRepositoryUnlocked()
        if !s:AskForMasterPassword()
          " if cannot open secure repository
          return ''
        endif
      endif
      if s:profiles.IsSecureRepositoryUnlocked()
        let password = a:pwd
      endif
    endif
  endif
  return password
endfunction"}}}

" Ask the user for the current master password.
function! s:AskForMasterPassword()"{{{
  let valid = 0
  if s:profiles.IsSecureRepositoryInitialized()
    while !valid
      let master_password = inputsecret('Master password: ')
      if s:profiles.OpenMasterRepository(master_password)
        break
      else
        call voraxlib#utils#Warn("Wrong password!\n")
      endif
    endwhile
    return 1
  else
    call voraxlib#utils#Warn('Cannot access the secure repository!\n')
    return 0
  endif
endfunction"}}}

" Ask the user for the master repository creation.
function! s:PromptForCreateSecureKeys()"{{{
  echo 'To store the password for this connection a secure repository'
  echo 'must be created.'
  echo ''
  let response = voraxlib#utils#PickOption(
        \ 'Do you want to create it now?',
        \ ['(Y)es', '(N)o'])
  if response == 'Y'
    while 1
      let master_password = inputsecret('Master password: ')
      if len(master_password) < 6
        call voraxlib#utils#Warn("Please provide a password with at least 6 chars!")
      else
      	" password length okey
      	break
      end
    endwhile
    if master_password != ''
      call s:profiles.CreateSecureKeys(master_password)
      return 1
    else
      echo 'Abort!'
      return 0
    endif
  else
  	return 0
  endif
endfunction"}}}

" Ask the user if for a category.
function! s:PromptForCategory()"{{{
  let category = ''
  let response = voraxlib#utils#PickOption(
        \ 'Do you want to assign this profile to a category?',
        \ ['(Y)es', '(N)o'])
  if response == 'Y'
    let category = input('Category: ', '', 
          \ 'customlist,voraxlib#panel#profiles#CategoriesList')
  endif
  return category
endfunction"}}}

" Click for the current profile. This is a dummy function which is called from
" the tree key mapping.
function! s:Click()"{{{
  call s:profiles.ClickNode(s:profiles.GetCurrentNode())
endfunction"}}}

" Toggle the important flag for the provided node.
function! s:ToggleImportantCurrentNode()"{{{
  let crr_node = s:profiles.GetCurrentNode()
  if !s:profiles.IsCategory(crr_node)
    let profile_name = s:profiles.GetProfileNameFromPath(crr_node)
    let profile = s:profiles.GetProfile(profile_name)
    call s:profiles.ToggleImportant(profile)
    call s:profiles.RefreshProfile(profile)
  endif
endfunction"}}}

" Invoke the contextual menu.
function! s:InvokeMenu()"{{{
  let crr_node = s:profiles.GetCurrentNode()
  if crr_node == s:profiles.root
    " the root node
    let response = voraxlib#utils#PickOption(
          \ 'Profiles MENU:',
          \ ['(A)dd new profile'])
    if response == 'A'
      call s:profiles.Add('', {})
    endif
  elseif s:profiles.IsCategory(crr_node)
    " a category node
    let response = voraxlib#utils#PickOption(
          \ 'Profiles MENU:',
          \ ['(A)dd new profile', 'Add new profile (h)ere'])
    if response == 'A'
      call s:profiles.Add('', {'category' : s:profiles.GetCategory(crr_node)})
    elseif response == 'h'
      call s:profiles.Add('', {'category' : s:profiles.GetCategory(crr_node)})
    endif
  elseif !s:profiles.IsCategory(crr_node)
    " a profile node
    let response = voraxlib#utils#PickOption(
          \ 'Profiles MENU:',
          \ ['(A)dd new profile', 'Add new profile (h)ere', '(R)emove profile', 'Toggle (i)mportant'])
    if response == 'A'
      call s:profiles.Add('', {})
    elseif response == 'h'
      call s:profiles.Add('', {'category' : s:profiles.GetCategory(crr_node)})
    elseif response == 'R'
      call s:profiles.RemoveProfile(s:profiles.BuildProfileFromPath(crr_node))
      echo s:profiles.GetProfileNameFromPath(crr_node) . ' deleted.'
    elseif response == 'i'
      call s:ToggleImportantCurrentNode()
    endif
  endif
endfunction"}}}

let &cpo = s:cpo_save
unlet s:cpo_save
