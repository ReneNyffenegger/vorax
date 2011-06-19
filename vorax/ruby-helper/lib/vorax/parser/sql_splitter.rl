#!/usr/bin/ragel -R

module Vorax

  module SqlSplitter

    %%{
      machine sqlsplitter;

      action is_eof {
      	true if p == eof - 1
      }
      
      # eof
      EOF = zlen when is_eof;
      
      # strings
      squoted_string = ['] ( (any - [''])** ) ['];
      dquoted_string = '"' ( any )* :>> '"';
                   
      # comments
      ml_comment = '/*' ( any )* :>> '*/';
      sl_comment = '--' ( any )* :>> ('\n' | EOF);

      # the common separator (single line)
      separator_1 = ';';
      separator_2 = (sl_comment | '\n') [ \t]* '/' [ \t]* ('\n' | EOF);
      separator = separator_1 | separator_2;

      # ignore shit
      shit = alnum+ | space+;

      main := |*
        squoted_string;
        dquoted_string;
        ml_comment;
        sl_comment;
        separator => { @markers << te };
        shit;
        any;
      *|;

    }%%

    %% write data;

    def SqlSplitter.split(data)
      # convert the provided string in a stream of chars
      stream_data = data.unpack("c*") if(data.is_a?(String))
      eof = stream_data.length
      # the array with separator markers. The beginning of the
      # string is always considered a marker.
      @markers = [0]
            
      %% write init;
      %% write exec;

      # add the end marker as the end of the string
      @markers << eof unless @markers.include?(eof)

      # split into statements now
      statements = []
      0.upto(@markers.length-2) do |index|
        statements << data[(@markers[index] ... @markers[index+1])]
      end
      # remove the last statement if it's comprised of whitespace only
      statements.delete_at(-1) if statements.last =~ /\A[ \t\r\n]*\Z/
      statements
    end

  end

end
