module Vorax

  # The WINDOWS implementation for inter-process comunication
  class WindowsProcess
    
    # process interface contract
    include GenericProcess

    attr_reader :pid

    # create a new process with the provided command
    def create(command)
      require 'rubygems'
      require 'Win32API'
      
      # create 3 pipes
      child_in_r, @writer = create_pipe        # stdin
      @reader, child_out_w = create_pipe      # stdout
      child_error_r, child_error_w = create_pipe  # sterr


      # Ensure the write handle to the pipe for STDIN is not inherited.
      set_handle_information(@writer, HANDLE_FLAG_INHERIT, 0)
      set_handle_information(@reader, HANDLE_FLAG_INHERIT, 0)
      set_handle_information(child_error_r, HANDLE_FLAG_INHERIT, 0)
      
      # Create the external sqlplus process
      @pid, threadId = create_process(command, 
                                      child_in_r, 
                                      child_out_w, 
                                      child_error_w)

      # we have to close the handles, so the pipes terminate with the process
      close_handle(child_in_r)
      close_handle(child_out_w)
      close_handle(child_error_w)
    end

    # send text to the process
    def write(text)
      write_file(@writer, text.to_s)
    end

    # read the provided number of bytes from
    # the process output
    def read(bytes)
      read_file(@reader, bytes) unless peek_named_pipe(@reader).zero?
    end

    def cancel
      # On Windows cancelling the currently executing statement is not supported.
      raise NotImplementedError.new
    end
    
    private

    # define various constants for win32 stuff
    NORMAL_PRIORITY_CLASS = 0x00000020 unless defined?(NORMAL_PRIORITY_CLASS)
    STARTUP_INFO_SIZE = 68 unless defined?(STARTUP_INFO_SIZE)
    SECURITY_ATTRIBUTES_SIZE = 12 unless defined?(SECURITY_ATTRIBUTES_SIZE)
    HANDLE_FLAG_INHERIT = 1 unless defined?(HANDLE_FLAG_INHERIT)

    ERROR_SUCCESS = 0x00 unless defined?(ERROR_SUCCESS)
    FORMAT_MESSAGE_FROM_SYSTEM = 0x1000 unless defined?(FORMAT_MESSAGE_FROM_SYSTEM)
    FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x2000 unless defined?(FORMAT_MESSAGE_ARGUMENT_ARRAY)

    STARTF_USESHOWWINDOW = 0x00000001 unless defined?(STARTF_USESHOWWINDOW)
    STARTF_USESTDHANDLES = 0x00000100 unless defined?(STARTF_USESTDHANDLES)

    # Get the last returned kernel error.
    def raise_last_win_32_error
      errorCode = Win32API.new("kernel32", "GetLastError", [], 'L').call
      if errorCode != ERROR_SUCCESS
        params = [
          'L', # IN DWORD dwFlags,
          'P', # IN LPCVOID lpSource,
          'L', # IN DWORD dwMessageId,
          'L', # IN DWORD dwLanguageId,
          'P', # OUT LPSTR lpBuffer,
          'L', # IN DWORD nSize,
          'P', # IN va_list *Arguments
        ]

        formatMessage = Win32API.new("kernel32", "FormatMessage", params, 'L')
        msg = ' ' * 255
        msgLength = formatMessage.call(FORMAT_MESSAGE_FROM_SYSTEM +
          FORMAT_MESSAGE_ARGUMENT_ARRAY, '', errorCode, 0, msg, 255, '')

        msg.gsub!(/\000/, '')
        msg.strip!
        raise msg
      end
    end

    # Create a Windows pipe and it returns the read and
    # write handlers for this pipe.
    def create_pipe 
      params = [
        'P', # pointer to read handle
        'P', # pointer to write handle
        'P', # pointer to security attributes
        'L'] # pipe size
      createPipe = Win32API.new("kernel32", "CreatePipe", params, 'I')

      read_handle, write_handle = [0].pack('I'), [0].pack('I')
      sec_attrs = [SECURITY_ATTRIBUTES_SIZE, 0, 1].pack('III')

      raise_last_win_32_error if createPipe.Call(read_handle,
        write_handle, sec_attrs, 0).zero?

      [read_handle.unpack('I')[0], write_handle.unpack('I')[0]]
    end

    # Set properties for the provided handler.
    def set_handle_information(handle, flags, value)
      params = [
        'L', # handle to an object
        'L', # specifies flags to change
        'L'] # specifies new values for flags

      setHandleInformation = Win32API.new("kernel32",
        "SetHandleInformation", params, 'I')
      raise_last_win_32_error if setHandleInformation.Call(handle,
        flags, value).zero?
      nil
    end

    # Close the provided handler.
    def close_handle(handle)
      closeHandle = Win32API.new("kernel32", "CloseHandle", ['L'], 'I')
      raise_last_win_32_error if closeHandle.call(handle).zero?
    end

    # Creates an external process given the provided OS command and
    # links the stdin, stdout and stderr to the provided handlers. It
    # returns the pid of the process and its thread identifier.
    def create_process(command, stdin, stdout, stderror)
      params = [
        'L', # IN LPCSTR lpApplicationName
        'P', # IN LPSTR lpCommandLine
        'L', # IN LPSECURITY_ATTRIBUTES lpProcessAttributes
        'L', # IN LPSECURITY_ATTRIBUTES lpThreadAttributes
        'L', # IN BOOL bInheritHandles
        'L', # IN DWORD dwCreationFlags
        'L', # IN LPVOID lpEnvironment
        'L', # IN LPCSTR lpCurrentDirectory
        'P', # IN LPSTARTUPINFOA lpStartupInfo
        'P']  # OUT LPPROCESS_INFORMATION lpProcessInformation

      startupInfo = [STARTUP_INFO_SIZE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW, 0,
        0, 0, stdin, stdout, stderror].pack('IIIIIIIIIIIISSIIII')

      processInfo = [0, 0, 0, 0].pack('IIII')
      command << 0

      createProcess = Win32API.new("kernel32", "CreateProcess", params, 'I')
      raise_last_win_32_error if createProcess.call(0,
        command, 0, 0, 1, 0, 0, 0, startupInfo, processInfo).zero?

      hProcess, hThread, dwProcessId, dwThreadId = processInfo.unpack('LLLL')

      close_handle(hProcess)
      close_handle(hThread)

      [dwProcessId, dwThreadId]
    end

    # write the provided buffer to the provided handler. This handler may point
    # to a file or a pipe.
    def write_file(hFile, buffer)
      params = [
        'L', # handle to file to write to
        'P', # pointer to data to write to file
        'L', # number of bytes to write
        'P', # pointer to number of bytes written
        'L'] # pointer to structure for overlapped I/O

      written = [0].pack('I')
      writeFile = Win32API.new("kernel32", "WriteFile", params, 'I')

      raise_last_win_32_error if writeFile.call(hFile, buffer, buffer.size,
        written, 0).zero?

      written.unpack('I')[0]
    end

    # Read from the provided handler (file or pipe). It returns the
    # read buffer as a plain string.
    def read_file(hFile, bytes)
      params = [
        'L', # handle of file to read
        'P', # pointer to buffer that receives data
        'L', # number of bytes to read
        'P', # pointer to number of bytes read
        'L'] #pointer to structure for data

      number = [0].pack('I')
      buffer = ' ' * bytes

      readFile = Win32API.new("kernel32", "ReadFile", params, 'I')
      return '' if readFile.call(hFile, buffer, 32767, number, 0).zero?

      buffer[0...number.unpack('I')[0]]
    end

    # Peek into the provided pipe.
    def peek_named_pipe(hFile)
      params = [
        'L', # handle to pipe to copy from
        'L', # pointer to data buffer
        'L', # size, in bytes, of data buffer
        'L', # pointer to number of bytes read
        'P', # pointer to total number of bytes available
        'L'] # pointer to unread bytes in this message

      available = [0].pack('I')
      peekNamedPipe = Win32API.new("kernel32", "PeekNamedPipe", params, 'I')

      if peekNamedPipe.Call(hFile, 0, 0, 0, available, 0).zero?
        raise IOError, 'Named pipe unavailable'
      end

      available.unpack('I')[0]
    end

  end
end
