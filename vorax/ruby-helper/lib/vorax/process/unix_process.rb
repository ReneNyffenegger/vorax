module Vorax

  # The UNIX implementation for inter-process comunication
  class UnixProcess
    
    # interface contract
    include GenericProcess

    attr_reader :pid
    
    # How many seconds to wait for a process to vanish after
    # a destroy request
    DESTROY_TIMEOUT = 10

    # create a new process. 
    def create(command)
      require 'pty'
      @reader, @writer, @pid = PTY.spawn(command)
      @writer.sync = true
      @reader.sync = true
    end

    # send text to the process
    def write(text)
      @writer.print(text)
    end

    # read the provided number of bytes from
    # the process output
    def read(bytes)
      @reader.read_nonblock(bytes)
    rescue Errno::EAGAIN
      # it simply means that there's nothing in
      # the output buffer.
    rescue Errno::EIO => msg
      @pid = nil
    end

    def destroy
      Process.kill(9, @pid)
      # confirm that the process was really killed
      begin
        (DESTROY_TIMEOUT*10).times do 
          read(1)
          sleep 0.1
        end
        raise "Timeout while trying to kill the sqlplus process."
      rescue PTY::ChildExited => msg  
        # the process has been destoryed
        @pid = nil
      end
    end

  end
end
