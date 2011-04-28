module Vorax

  # That's the interface VoraX expects for
  # communicating with an external process
  module GenericProcess

    # Create a process using the provided command.
    def create(command)
      raise "create(command) must be overridden"
    end

    # Send the provided text to the process.
    # In case of commands it's up to
    # the caller to also send the CR at the end.
    def send(text)
      raise "send(text) must be overridden"
    end

    # Reads the provided number of bytes from
    # the output of the external process.
    def read(bytes)
      raise "read(bytes) must be overridden"
    end

    # Cancel the current operation in sqlplus
    def cancel
      Process.kill(INT, pid)
    end

    # Kill the attached process
    def destroy
      Process.kill(9, pid)
    end

    # Get the pid of the process.
    def pid
      raise "pid() must be overridden"
    end


  end

end
