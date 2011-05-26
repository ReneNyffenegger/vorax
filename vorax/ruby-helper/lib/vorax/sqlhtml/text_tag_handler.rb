module Vorax

  # Handler for text nodes.
  class TextTagHandler < AbstractTagHandler

    def visit(node)
      node.text if node.name == 'text'
    end

  end

end
