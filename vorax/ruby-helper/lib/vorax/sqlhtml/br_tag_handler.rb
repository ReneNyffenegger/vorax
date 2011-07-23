module Vorax

  # Handler for <p> nodes.
  class BrTagHandler < AbstractTagHandler

    def visit(node, handlers)
      if node.name == 'br'
        return "\n"
      end
    end

  end

end

