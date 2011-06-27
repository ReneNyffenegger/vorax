require 'vorax/sqlhtml/abstract_tag_handler.rb'
require 'vorax/sqlhtml/table_tag_handler.rb'
require 'vorax/sqlhtml/p_tag_handler.rb'
require 'vorax/sqlhtml/text_tag_handler.rb'

module Vorax

  class SqlHtmlBeautifier

    def initialize()
      @registered_tag_handlers = []
    end

    def register_tag_handler(tag_handler)
      @registered_tag_handlers << tag_handler
    end

    def unregister_tag_handler(tag_handler)
      @registered_tag_handlers.delete(tag_handler)
    end

    def beautify(html)
      body = Nokogiri::HTML(html.gsub(/&amp;/, '&amp;amp;'), nil, 'utf-8').xpath('/html/body')
      return walk(body)
    end

    private

    def walk(element)
      buf = ''
      element.children.each do |child|
        # walk just for the first level of children (depth = 1)
        @registered_tag_handlers.each do |h|
          buf << h.visit(child).to_s
        end
      end
      return buf
    end

  end

end
