module Vorax

  # Handler for <p> nodes.
  class BTagHandler < AbstractTagHandler

    def visit(node, handlers)
      buffer = ''
      if node.name == 'b'
        node.children.each { |n| buffer << CGI.unescapeHTML(n.to_s.gsub(/[\r\n]/, '')) if n.text? }
      end
      buffer
    end

  end

end

