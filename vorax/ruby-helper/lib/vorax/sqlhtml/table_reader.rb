module Vorax

  module TableReader

    def TableReader.extract(html)
      resultset = []
      errors = []
      record = {}
      columns = []
      body = Nokogiri::HTML(html, nil, 'utf-8').xpath('/html/body')
      # search for errors
      body.children.each do |child|
        if child.name == 'text'
          value = CGI.unescapeHTML(tr.text.mb_chars.gsub(/(\A\r?\n)|(\r?\n\Z)/, '').to_s)
          if value =~ '^(ORA|SP[0-9]?\|PLS)-[0-9]\+'
            errors << value
          end
        end
      end
      table = body.xpath('table[1]')
      table.xpath("tr[1]/th").each { |col| columns << CGI.unescapeHTML(col.text).strip }
      idx = 0
      table.xpath('tr/*').each do |tr|
        if tr.name == 'td'
          value = CGI.unescapeHTML(tr.text.mb_chars.gsub(/(\A\r?\n)|(\r?\n\Z)/, '').to_s)
          record[columns[idx]] = value
          idx += 1
          if idx == columns.count
            idx = 0
            resultset << record
            record = {}
          end
        end
      end
      {'resultset' => resultset, 'errors' => errors}
    end

  end

end
