module Vorax

  # Handler for text nodes.
  class TextTagHandler < AbstractTagHandler

    def visit(node)
      node.text.chomp if node.name == 'text'
    end

  end

end
