module Vorax

  # Handler for <p> nodes.
  class PTagHandler < AbstractTagHandler

    def visit(node, handlers)
      buffer = ''
      if node.name == 'p'
        buffer << "\n"
        node.children.each do |n| 
          if n.text?
            buffer << CGI.unescapeHTML(n.to_s.gsub(/[\r\n]/, ''))
          else
            # expect other child nodes within the <p> tag
            handlers.each do |h|
              buffer << h.visit(n, handlers).to_s
            end
          end
        end
      end
      buffer
    end

  end

end
