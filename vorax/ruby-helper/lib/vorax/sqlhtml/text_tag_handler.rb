module Vorax

  # Handler for text nodes.
  class TextTagHandler < AbstractTagHandler

    def visit(node, handlers)
      CGI.unescapeHTML(node.text.to_s.gsub(/[\r\n]/, '')) if node.name == 'text'
    end

  end

end
