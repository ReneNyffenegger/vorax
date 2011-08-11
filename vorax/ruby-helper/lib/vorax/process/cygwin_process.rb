module Vorax
  
  class CygwinProcess < UnixProcess

    def convert_path(path)
      win_path = `cygpath -w #{shellescape(path)}`
      return win_path.gsub(/\r?\n/, '')
    end

    private

    def shellescape(str)
      # An empty argument will be skipped, so return empty quotes.
      return "''" if str.empty?

      str = str.dup

      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored.
      str.gsub!(/\n/, "'\n'")

      return str
    end


  end

end
