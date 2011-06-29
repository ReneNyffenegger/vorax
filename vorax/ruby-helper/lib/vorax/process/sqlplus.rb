module Vorax
  
  # An actual sqlplus process implementation.
  class Sqlplus

    attr_reader :connected_to,          # user@db session
                :startup_msg,           # sqlplus initialization message (banner)
                :session_owner_monitor, # monitoring mode
                :tmp_dir,               # the sqlplus tmp directory
                :local_login_warning    # whenever or not the current directory already have a login.sql file

    attr_reader :read_buffer_size     # the default read chunk size

    # Create a new sqlplus abstraction. The initializer expects
    # a GenericProcess compliant object, specific to the current
    # OS platform. The bootstrap_commands are statements to be
    # executed at the sqlplus initialization time. The tmp_dir parameter specifies
    # the directory under which the sqlplus process should create temp files. This doesn't
    # change the current directory.
    # If debug is true than the output of the sqlplus is also redirected to
    # the sqlplus.log file. The "tee" utility must be available.
    # The sqlplus_params allows to specify sqlplus additional
    # parameters (e.g. -S for silence).
    def initialize(process, bootstrap_commands = [], tmp_dir = Dir.tmpdir, debug = false, sqlplus_params = "")
      @tmp_dir = tmp_dir
      if process
        begin
          @read_buffer_size = [32767, END_OF_REQUEST.bytesize].max
          @process = process
          # env path separator
          separator = ':'
          if RUBY_PLATFORM.downcase.include?("mswin") ||
              RUBY_PLATFORM.downcase.include?("mingw")
            # on windows is ';'
            separator = ';' 
          end
          if File.exists?('login.sql')
            @local_login_warning = true
          else
            # put the tmp_dir first on SQLPATH so that, the vorax generated login.sql to be found first in case the
            # session_owner_monitor is set to :on_login. This has to be set here in order the sqlplus process to inherit
            # this setting.
            ENV['SQLPATH'] = "#{tmp_dir}#{separator}#{ENV['SQLPATH']}"
            @local_login_warning = false
          end
          @process.create("sqlplus #{sqlplus_params} /nolog #{pack(bootstrap_commands, '_vorax_bootstrap.sql', true)}" + 
                          (debug ? " | tee sqlplus.log" : ""))
          # contain the current connected user@db, but
          # only if connection monitor is activated
          @connected_to = "@"
          # the @tail stores the last chunks of read output.
          # That's needed in order to find out the END_OF_REQUEST marker.
          # The tail size is the length of the END_OF_REQUEST marker just
          # to be on the safe side in case the read is very slow and returns
          # on byte at a time which implies a lot of breaks just within the
          # END_OF_REQUEST marker.
          @tail = RingBuffer.new(END_OF_REQUEST.bytesize)
          # no connection monitor by default
          session_owner_monitor = :never
          # unless the sqlplus is completely initialize set it as busy
          @busy = true
          # stuff after the END_OF_REQUEST marker
          @residual = "" # at the very beginning assume nothing residual
          @startup_msg = "" # that's the stuff spit by sqlplus at startup time
          while buf = self.read()
            @startup_msg << buf
          end
        end
      else
        raise 'A process implementation must be provided'
      end
    end

    # Set the default read buffer size. It should be never less of the END_OF_REQUEST length.
    def read_buffer_size=(size)
      @read_buffer_size = [size, END_OF_REQUEST.bytesize].max
    end

    # The pid of the sqlplus process.
    def pid
      @process.pid
    end

    # Send text to the sqlplus process.
    def <<(text)
      @process.write(text) if text
    end

    # Exec the provided command. The method returns the output of the 
    # command as a plain string. An optional block may be provided which
    # is invoked on every chunk of data read. This is usefull to update
    # progress info.
    def exec(command)
      nonblock_exec(command)
      output = ""
      while buf = self.read()
        output << buf
        yield if block_given?
      end
      output
    end

    # Async exec of the provided command. The execution of a command is
    # serialized so that you cannot run two statements in parallel. If
    # you try to the second exec will raise a "busy" exception. This
    # method returns immediatelly but it's up to the caller to async
    # read the corresponding output. The sqlplus process will remain
    # busy unless the output is read till the END_OF_REQUEST marker.
    def nonblock_exec(command, include_eor = true)
      raise "Sqlplus busy executing another command." if busy?
      # set as busy in order to prohibit executing other commands
      @busy = true
      self << "#{command}\n"
      # mark the end of the request
      self << "prompt #{END_OF_REQUEST}\n" if include_eor
    end

    # Set the session owner monitor mode. If activated, after every exec
    # a check will be performed in order to see if the connected
    # user@db has changed. There are three possible modes:
    #   :never    => the session monitor is disabled
    #   :always   => after every exec the currently user@db info is
    #                gathered from the database.
    #                DRAWBACKS: performance penalty, DBMS_XPLAN
    #                issues.
    #   :on_login => the user@db info is gathered only after a new
    #                logon is detected. This is done by creating a 
    #                login.sql file into the current directory (most 
    #                likely a Vorax temp dir) which will be automatically 
    #                called by sqlplus. In order to avoid overwriting 
    #                the user's login.sql file, this method search for a
    #                login.sql file within the $SQLPATH and if such a 
    #                file is found then its content is injected into 
    #                the generated temp login.sql file. The generated 
    #                login.sql file creates a dummy file called 
    #                "connection_changed.{sqlplus_pid}". After every 
    #                exec, if connection monitoring is activated then 
    #                we look up for this file and if it's there it means 
    #                that the connection has changed.
    #                DRAWBACKS: doesn't reset the user@db after a
    #                disconnect command.
    def session_owner_monitor=(mode)
      return if @session_owner_monitor == mode # forget it if no state change
      @session_owner_monitor = mode
      if @session_owner_monitor == :on_login
        @conn_changed_file = "_vorax_connection_changed.#{pid}"
        login_file_content = ''
        # is the SQLPATH variable initialized?
        if sqlpath = ENV['SQLPATH']
          # skip the first path because it's our temp location
          paths = sqlpath.split(/[;:]+/)[(1..-1)]
          if paths
            paths.each do |path|
              # for every path in SQLPATH search for login.sql file
              if File.exists?("#{path}/login.sql")
                # file found
                File.open("#{path}/login.sql") { |f| login_file_content << f.read }
                break
              end
            end
          end
        end
        login_file_content << "host echo  > #@tmp_dir/#@conn_changed_file" 
        File.open("#@tmp_dir/login.sql", 'w') { |f| f.puts(login_file_content) }
      elsif @session_owner_monitor == :never || @session_owner_monitor == :always
        @connected_to = '@' if @session_owner_monitor == :never
        File.delete("#@tmp_dir/login.sql") if File.exists?("#@tmp_dir/login.sql")
      end
    end

    # Read the provided number of bytes from the sqlplus output. It
    # returns the data as a String or nil if END_OF_REQUEST has been
    # reached. Pay attention that while waiting for output from the
    # sqlplus process the read method may return an empty string. This
    # doesn't mean that the END_OF_REQUEST was reached but that the
    # statement is still executing and there's no output available yet.
    def read(bytes=read_buffer_size)
      bytes = [bytes, END_OF_REQUEST.bytesize].max
      if busy? && pid
        # check if there's any residual output form the previous exec.
        if @residual != ""
          # there's something residual... return it at the beginning of
          # the chunk
          chunk = @residual
          @residual = ""
        else
          chunk = ""
        end
        buf = @process.read(bytes)
        chunk << buf if buf
        if chunk != ""
          @tail.push(buf) if buf
          tail_str = @tail.join
          # check the tail for the END_OF_REQUEST marker
          if tail_str =~ /#{END_OF_REQUEST}/
            # GREAT: the end of the request has been detected!
            # everything after END_OF_REQUEST save as residual stuff
            #@residual = tail_str[Regexp.last_match.end(0)..-1]
            @residual = ''
            # remove the line containing the END_OF_REQUEST from chunk
            chunk.slice!(/[^\n]*#{END_OF_REQUEST}[^\Z]*/)
            # get rid of the tail content... we don't need it anymore
            @tail.clear
            # the sqlplus is no longer busy
            @busy = false
            # get the currently connected user@db
            if gather_session_owner?
              @connected_to = session_owner
              File.delete("#@tmp_dir/#@conn_changed_file") if @session_owner_monitor == :on_login
            end
          else
            # be prepared for breaks within the END_OF_REQUEST marker
            postpone_tail!(chunk) if buf
          end
        else
          # the sqlplus is executing but it doesn't spit any output,
          # therefore just wait a little bit
          sleep READ_SLEEP_TICK
        end
      else
        # no output to return... there's nothing executing out there
        chunk = nil
      end
      chunk
    end

    # Get the current sqlplus setting for the provided
    # attributes (e.g. echo, verify, define etc.)
    def config_for(*settings)
      # store the actual configuration
      settings_file = "#@tmp_dir/_vorax_sqlplus_settings.#{pid}"
      exec("store set #{settings_file} replace")
      # compute regexp pattern
      patterns = []
      settings.flatten.each { |s| patterns << "(^set #{s})" }
      match_pattern = /#{patterns.join('|')}/
      result = []
      setting = ""
      File.open(settings_file) do |f|
        while line = f.gets
          if line =~ match_pattern || setting != ""
            if line =~ /-$/
              # it means a very long value for the setting which continues on the next line
              setting += line
            else
              setting += line.chomp
              result << setting
              # reset the setting
              setting = ''
            end
          end
        end
      end
      result
    end
    
    # Is the sqlplus currently busy executing something?
    def busy?
      @busy
    end

    # Cancel the currently executing statement.
    def cancel
      # send cancel signal
      @process.cancel
      self << "\n"
      self << "prompt #{CANCEL_MARKER}\n"
      chunk = "" 
      while true
        buf = @process.read(@read_buffer_size)
        yield if block_given?
        if buf
          chunk << buf
          if chunk =~ /#{CANCEL_MARKER}/
            break
          end
        else
          # just wait a little bit
          sleep READ_SLEEP_TICK
        end
      end
      # not busy anymore.
      @busy = false
      # some dirty output still remains after a cancel. The following is a
      # workaround to trash it!
      exec("\n")
    end

    # Kill the attached sqlplus process
    def destroy
      @process.destroy if pid
    end

    # pack the provided commands into a sql file. It returns
    # the name of the sql file prefixed with @.
    def pack(commands = [], filename = DEFAULT_PACK_FILE, include_eor = false)
      # the bootstrap file is created in the current directory. However,
      # it is expected that VoraX will arrange things so that the crr
      # directory will be under $TEMP.
      cmds = (commands.nil? ? [] : commands)
      file_content = cmds.join("\n")
      file_content << "\nprompt #{END_OF_REQUEST}\n" if include_eor
      filename = DEFAULT_PACK_FILE if filename.nil?
      File.open("#@tmp_dir/#{filename}", 'w') {|f| f.write(file_content) }
      "@#@tmp_dir/#{filename}"
    end

    # Get the user@db for the current sqlplus session.
    def session_owner
      # the following session_owner_monitor stuff is a trick in
      # order to avoid recursive calls, because: exec calls read
      # and read calls session_owner and session_owner calls (again)
      # exec.
      monitor = @session_owner_monitor # save the current monitoring
      @session_owner_monitor = :skip   # skip monitoring
      commands = ['set define "&"', 
                  'prompt <conn>&_USER@&_CONNECT_IDENTIFIER</conn>', 
                  *config_for('define')]
      output = exec(commands.join("\n"))
      @session_owner_monitor = monitor # restore monitoring
      if output =~ /<conn>(.*?)<\/conn>/
        connect_profile = $1
      else
        connect_profile = '@'
      end
    end

    private
    
    # This is the end marker till the output from
    # the sqlplus process must be read after executing
    # a statement.
    END_OF_REQUEST = '~~~ VORAX_END_OF_REQUEST ~~~' unless defined?(END_OF_REQUEST)

    # This marker is used to mark a cancel request.
    CANCEL_MARKER = '~~~ VORAX_CANCEL_REQUEST ~~~' unless defined?(CANCEL_MARKER)

    # Where to pack the sql commands by default.
    DEFAULT_PACK_FILE = "run_this.sql" unless defined?(DEFAULT_PACK_FILE)

    # If there's no data to read from the sqlplus output how long
    # (in seconds) to wait till the next read.
    READ_SLEEP_TICK = 0.03 unless defined?(READ_SLEEP_TICK)

    # Check if the process with the provided PID still exists.
    def pid_exists?(proc_pid)
      Process.getpgid( proc_pid )
      true
    rescue Errno::ESRCH
      false
    end

    # Inspects the tail of the provided chunk in order to figure out
    # if it is part of the END_OF_REQUEST marker. The part of tail
    # which match it is put into the @residual container being
    # postponed for the next read. This method effectively change
    # the provided chunk by removing the part which matches the
    # END_OF_REQUEST marker.
    def postpone_tail!(chunk)
      i = chunk.length - 1
      (chunk.length-1).downto([chunk.length - END_OF_REQUEST.length - 1, 0].max) do |i|
        unless END_OF_REQUEST[chunk[i..-1]]
          # break the loop only if the tail does not match
          # with the END_OF_REQUEST marker
          break
        end
      end
      @residual = chunk[i..-1]
      if i > 0
        chunk.slice!(i..-1)
      else
        chunk.slice!(0..-1)
      end
      chunk
    end

    # Should the session owner information gathered?
    def gather_session_owner?
      (@session_owner_monitor == :always) || 
        (@session_owner_monitor == :on_login && 
         File.exists?("#@tmp_dir/#@conn_changed_file"))
    end


  end
end
