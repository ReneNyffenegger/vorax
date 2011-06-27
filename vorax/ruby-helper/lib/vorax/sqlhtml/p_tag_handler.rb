module Vorax

  # Handler for <p> nodes.
  class PTagHandler < AbstractTagHandler

    def visit(node)
      buffer = ''
      if node.name == 'p'
        node.children.each { |n| buffer << n.to_s if n.text? }
      end
      buffer
    end

  end

end
