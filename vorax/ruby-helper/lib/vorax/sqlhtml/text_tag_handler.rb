module Vorax

  # Handler for text nodes.
  class TextTagHandler < AbstractTagHandler

    def visit(node)
      CGI.unescape(node.text.chomp) if node.name == 'text'
    end

  end

end
