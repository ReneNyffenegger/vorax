module Vorax

  # Table handler
  class TableTagHandler < AbstractTagHandler

    def initialize(colsep = ' ', underline = '-', recsep = false, recsepchar = '')
      # column separator
      @colsep = colsep
      # the char used to underline
      @underline = underline
      # should records be separated
      @recsep = recsep
      # the separator char for records
      @recsepchar = recsepchar
    end

    def visit(node)
      if node.name == 'table'
        buffer = ''
        # how many columns do we have?
        cols = node.xpath('tr[1]/th|tr[1]/td').count
        # compute the structure of the table as [[<length of the column>, <number_or_right_align_flag>] ... ]
        structure = []
        (0..cols-1).each do |rn|
          structure << node.xpath("tr/th[#{rn+1}]|tr/td[#{rn+1}]").inject([0, false]) do |result, element| 
            [ [result[0], u(element.text).strip.length].max, (result[1] || element.attribute('align'))] 
          end
        end
        line = []
        idx = 0
        i = 1
        node.xpath('tr/*').each do |tr|
          # walk through all columns of every record
          value = u(tr.text.gsub(/\n/, ' ')).strip
          if structure[idx][1]
            # it's a number so it must be right justified
            line << value.rjust(structure[idx][0])
          else
            # a regular string
            line << value.ljust(structure[idx][0])
          end
          idx += 1
          if idx == cols
            # great, we just finish with a record
            i += 1
            if tr.name == 'th'
              # it's the columns header with a new page. Just add a CR for pretty printing.
              buffer << "\n"
            end
            # add the record to the result buffer
            buffer << line.join(@colsep) << "\n"
            if tr.name == 'th'
              # add the line under the header if an underline char was provided
              buffer << ((line.collect { |e| @underline * e.length }).join(@colsep)) << "\n" if @underline != ''
            elsif @recsep
              # add a line for delimiting records
              buffer << ((line.collect { |e| @recsepchar * e.length }).join(@colsep.gsub(/./, @recsepchar))) << "\n"
            end
            # reset the line
            line.clear
            idx = 0
          end
        end
        buffer.chomp
      end
    end

  end

end
