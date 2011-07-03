module Vorax

  # An abstract class to handle various HTML tags
  class AbstractTagHandler

    # The string representation for this tag.
    def visit(node, handlers)
      throw RuntimeError.new('Implement me')
    end

  end

end
