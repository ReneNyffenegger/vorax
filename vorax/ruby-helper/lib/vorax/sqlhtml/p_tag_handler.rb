module Vorax

  # Handler for <p> nodes.
  class PTagHandler < AbstractTagHandler

    def visit(node)
      buffer = ''
      if node.name == 'p'
        buffer << "\n"
        node.children.each { |n| buffer << CGI.unescapeHTML(n.to_s.gsub(/[\r\n]/, '')) if n.text? }
      end
      buffer
    end

  end

end
