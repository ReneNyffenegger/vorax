module Vorax

  # An abstract class to handle various HTML tags
  class AbstractTagHandler

    # The string representation for this tag.
    def visit(node)
      throw RuntimeError.new('Implement me')
    end

  end

end
