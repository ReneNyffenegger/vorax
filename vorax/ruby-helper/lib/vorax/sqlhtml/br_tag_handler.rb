module Vorax

  # Handler for <p> nodes.
  class BrTagHandler < AbstractTagHandler

    def visit(node)
      if node.name == 'br'
        return "\n"
      end
    end

  end

end

