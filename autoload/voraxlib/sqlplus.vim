" Description: The SqlPlus interface to talk to an Oracle db.
" Mainainder: Alexandru Tica <alexandru.tica.at.gmail.com>
" License: Apache License 2.0

let s:cpo=&cpo
set cpo-=C

" the sqlplus object
let s:sqlplus = {'ruby_key' : '', 'last_stmt' : ''}

" the current object count. it is incremented on each new sqlplus object
" creation
let s:oc = 0

" the sqlplus factory contains all sqlplus processes managed through the
" ruby_helper
ruby $sqlplus_factory = {}

" Creates and returns a new Sqlplus object.
function! voraxlib#sqlplus#New() " {{{
  let sqlplus = copy(s:sqlplus)
  " the ruby_key is the link between this vim object and the sqlplus process
  " from the $sqlplus_factory
  let sqlplus.ruby_key = s:oc
  let s:oc += 1
  " define sqlplus run directory. Every new sqlplus instance gets a new temp
  " dir.
  let run_dir = substitute(fnamemodify(tempname(), ':p:h:8'), '\\', '/', 'g')
  " create the sqlplus process and put it into the oracle factory under the
  " ruby_key
  if has('unix')
    " unix interface
    ruby $sqlplus_factory[VIM::evaluate('sqlplus.ruby_key')] = Vorax::Sqlplus.new(Vorax::UnixProcess.new, VIM::evaluate('insert(copy(g:vorax_sqlplus_default_options), "host stty -echo", 0)'), VIM::evaluate('run_dir'))
  elseif has('win32') || has('win64')
    " windows interface
    ruby $sqlplus_factory[VIM::evaluate('sqlplus.ruby_key')] = Vorax::Sqlplus.new(Vorax::WindowsProcess.new, VIM::evaluate('g:vorax_sqlplus_default_options'), VIM::evaluate('run_dir'))
  endif
  return sqlplus
endfunction " }}}

" Get the PID of the sqlplus process behind
function! s:sqlplus.GetPid() dict " {{{
  ruby VIM::command("return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].pid}")
endfunction " }}}

" Get the default read buffer size
function! s:sqlplus.GetDefaultReadBufferSize() dict " {{{
  ruby VIM::command("return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].read_buffer_size}")
endfunction " }}}

" Set the default read buffer size
function! s:sqlplus.SetDefaultReadBufferSize(size) dict " {{{
  ruby $sqlplus_factory[VIM::evaluate('self.ruby_key')].read_buffer_size = VIM::evaluate('a:size')
endfunction " }}}

" Get the user@db session owner. The value depends on the current session
" owner monitor setting.
function! s:sqlplus.GetConnectedTo() dict " {{{
  ruby <<EORC
  conn = $sqlplus_factory[VIM::evaluate('self.ruby_key')].connected_to
  VIM::command(%[return '#{conn.gsub(/'/, "''")}']) 
EORC
endfunction " }}}

" Get the sqlplus startup message (banner)
function! s:sqlplus.GetBanner() dict "{{{
  ruby <<EORC
  banner = $sqlplus_factory[VIM::evaluate('self.ruby_key')].startup_msg
  banner.gsub!(/(\r?\n)*\Z/, '')
  VIM::command(%[return '#{banner.gsub(/'/, "''")}']) 
EORC
endfunction "}}}

" Get the session owner monitor mode. The meaning of the returned value is:
"   0 => NEVER, the session monitoring is disabled
"   1 => ON_LOGIN, the user@db (info returned by the ConnectedTo()) is updated
"   after a connect statement only.
"   2 => ALWAYS, the user@db info is updated after every SQL exec.
function! s:sqlplus.GetSessionOwnerMonitor() dict "{{{
  ruby <<EORC
  case $sqlplus_factory[VIM::evaluate('self.ruby_key')].session_owner_monitor
  when :never
    VIM::command("return 0")
  when :on_login
    VIM::command("return 1")
  when :always
    VIM::command("return 2")
  end
EORC
endfunction "}}}

" Set the session owner monitor mode. The expected a:mode is:
"   0 => NEVER, the session monitoring is disabled
"   1 => ON_LOGIN, the user@db (info returned by the ConnectedTo()) is updated
"   after a connect statement only.
"   2 => ALWAYS, the user@db info is updated after every SQL exec.
function! s:sqlplus.SetSessionOwnerMonitor(mode) dict "{{{
  if a:mode == 0 || a:mode == 1 || a:mode == 2
    ruby <<EORC
    $sqlplus_factory[VIM::evaluate('self.ruby_key')].session_owner_monitor = case VIM::evaluate('a:mode').to_i
    when 0
      :never
    when 1
      :on_login
    when 2
      :always
    end
EORC
  else
  	throw 'Invalid mode. Valid values are: 0, 1, 2.'
  endif
endfunction "}}}

" Get the sqlplus run directory (the directory from where the sqlplus was
" launched).
function! s:sqlplus.GetRunDir() dict "{{{
  ruby VIM::command(%!return '#{$sqlplus_factory[VIM::evaluate("self.ruby_key")].run_dir}'!)
endfunction "}}}

" Send text to the sqlplus process. May be used for interactive stuff (e.g.
" respond to an sqlplus ACCEPT command). The text is sent as it is therefore
" is up to the caller to also provide a CR if that's the intention.
function! s:sqlplus.SendText(text) dict "{{{
  ruby $sqlplus_factory[VIM::evaluate('self.ruby_key')] << VIM::evaluate('a:text')
endfunction "}}}

" Exec the provided command. The method returns the output of the 
" command as a plain string. This function accepts also an optional dictionary
" with additional attributes which are taken into account during the exec.
" The following structure is expected:
"   { 'executing_msg'  : '<message_to_be_displayed_during exec>',
"     'throbber'       : '<a throbber object instance>',
"     'done_msg'       : '<a message to be displayed when the exec completes>'
"     'sqlplus_options' : [option1, option2, ...] }
" The exectuing_msg is a text to be displayed during the exec (e.g. 'Executing...
" please wait...'). If a throbber is provided then this is also displayed thus
" providing an additional waiting feedback. The sqlplus_options is a list of
" sqlplus settings under which the command should be executed and at the end to be
" restored. The list of sqlplus options should have the following form:
" [{'option': '<sqlplus_option>', 'value' : '<option_value'}, ...]
" For example: [{'option' : 'termout', 'value' : 'on'},
"               {'option' : 'linesize', 'value' : '120'}]
" Once again, these settings are not permanent and are set just during the
" call. After that, they are restored to their original values.
function! s:sqlplus.Exec(command, ...) dict "{{{
  if self.GetPid()
    if a:0 > 0 && has_key(a:1, 'executing_msg')
      " if a message is provided
      echon a:1.executing_msg
    endif
    if a:0 > 0 && has_key(a:1, 'sqlplus_options')
      " exec under the provided options
      let requested_options = []
      let cmd = ''
      for option in a:1.sqlplus_options
        let cmd .= 'set ' . option['option'] . ' ' . option['value'] . "\n"
        call add(requested_options, option['option'])
      endfor
      let current_options = self.GetConfigFor(requested_options)
      ruby <<EORC
      $sqlplus_factory[VIM::evaluate('self.ruby_key')].exec(VIM::evaluate('cmd'))
EORC
    endif
    ruby <<EORC
    sqlplus = $sqlplus_factory[VIM::evaluate('self.ruby_key')]
    output = ""
    if VIM::evaluate('a:0 > 0 && (has_key(a:1, "throbber") || has_key(a:1, "executing_msg"))') == 1
      # exec with throbber
      output = sqlplus.exec(VIM::evaluate('a:command')) do
        msg = ""
        msg << VIM::evaluate('a:1.executing_msg"') if VIM::evaluate('has_key(a:1, "executing_msg")') == 1
        msg << ' ' << VIM::evaluate('a:1.throbber.Spin()') if VIM::evaluate('has_key(a:1, "throbber")') == 1
        VIM::command("redraw")
        VIM::command("echon #{msg.inspect}")
      end
    else
      # simple exec
      output = sqlplus.exec(VIM::evaluate('a:command'))
    end
    # restore settings
    if VIM::evaluate('exists("current_options")') == 1
      VIM::evaluate('current_options').each { |cmd| sqlplus.exec(cmd) }
    end
    # update title
    VIM::command('let &titlestring=' + sqlplus.connected_to.inspect) if sqlplus.session_owner_monitor != :never
    # display done msg
    VIM::command("redraw | echon #{VIM::evaluate('a:1.done_msg').inspect}") if VIM::evaluate('a:0 > 0 && has_key(a:1, "done_msg")') == 1
    VIM::command(%[return #{output.inspect}]) 
EORC
  else
    call voraxlib#utils#Warn('Invalid sqlplus process. Reconnect please!')
  endif
endfunction "}}}

" Asynchronously exec the provided command without waiting for the output. The
" result may be read in chunks afterwards using Read() calls.
function! s:sqlplus.NonblockExec(command) dict "{{{
  ruby $sqlplus_factory[VIM::evaluate('self.ruby_key')].nonblock_exec(VIM::evaluate('a:command'))
endfunction "}}}

" Asynchronously read the output from an sqlplus process. It is tipically
" invoked after a NonblockExec() call. You may provide an optional number of
" bytes to be read. If no size is given then the default read buffer size is
" used.
function! s:sqlplus.Read(...) dict "{{{
  if a:0 > 0
  	let buf_size = a:1
  else
  	let buf_size = self.GetDefaultReadBufferSize()
  endif
  ruby <<EORC
  output = $sqlplus_factory[VIM::evaluate('self.ruby_key')].read(VIM::evaluate('buf_size'))
  if output
    VIM::command(%!return #{output.inspect}!)
  end
EORC
endfunction"}}}

" Returns 1 (true) wherever the sqlplus process is busy executing something.
" This happens while in the middle of an Exec() or after an NonblockExec()
" till the whole output has been read.
function! s:sqlplus.IsBusy() dict "{{{
  ruby VIM::command(%!return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].busy? ? 1 : 0}!)
endfunction"}}}

" Get values for various sqlplus settings (e.g. autotrace, linesize etc.).
" This function expects a list of configuration names and returns the
" corresponding values into an array. The order is preserved so that, to the
" first option you provide, the first element into the returned array
" corresponds to. The output array contains actual sqlplus commands to be
" used in order to set the value for the given options.
function! s:sqlplus.GetConfigFor(...) dict"{{{
  if a:0 > 0
    " only if at least one param is provided
    ruby VIM::command(%!return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].config_for(VIM::evaluate('a:000')).inspect}!)
  else
  	return []
  endif
endfunction"}}}

" Pack several SQL commands provided through the a:commands array into the
" given optional target_file, specified as relative to the sqlplus run_dir. 
" Packing before executing is recommended especially in
" case of sending a lot of statements to be executed (e.g. packages,
" procedures, types etc.) but also if the SET ECHO ON feature is enabled and
" the user wants to have the list of executed statement displayed within the
" output window. 
" It returns the sqlplus command to actually execute all commands via the 
" pack file (e.g. @target_file)
function! s:sqlplus.Pack(commands, ...)"{{{
  if type(a:commands) == 3
    let commands = a:commands
  elseif type(a:commands) == 1
  	" we expect a list but if a string is provided than make the corresponding
  	" changes
  	let commands = add([], a:commands)
  else
  	" exit
  	return
  endif
  if a:0 > 0
    ruby VIM::command(%!return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].pack(VIM::evaluate('commands'), VIM::evaluate('a:1')).inspect}!)
  else
    ruby VIM::command(%!return #{$sqlplus_factory[VIM::evaluate('self.ruby_key')].pack(VIM::evaluate('commands')).inspect}!)
  endif
endfunction"}}}

" Cancel the currently executing command. On some platforms (Windows) this is
" not possible and this cancel operation ends up in an actual process kill.
function! s:sqlplus.Cancel() dict"{{{
  ruby <<EORC
  begin
    $sqlplus_factory[VIM::evaluate('self.ruby_key')].cancel
    $sqlplus_factory[VIM::evaluate('self.ruby_key')]<<"\n"
    $sqlplus_factory[VIM::evaluate('self.ruby_key')].exec("\n") do
      VIM::command('redraw')
      VIM::command('echon "Cancelling..."')
    end
    VIM::command('return 1')
  rescue
    VIM::command('return 0')
  end
EORC
endfunction"}}}

" Destroy the sqlplus process
function! s:sqlplus.Destroy() dict "{{{
  " get rid of the sqlplus process
  ruby $sqlplus_factory[VIM::evaluate('self.ruby_key')].destroy
  " delete the ruby object from the factory
  ruby $sqlplus_factory.delete(VIM::evaluate('self.ruby_key'))
endfunction "}}}

let &cpo=s:cpo

