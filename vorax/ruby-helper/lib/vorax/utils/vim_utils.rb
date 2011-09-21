module Vorax

  # Various utilities in connection with Vim.
  class VimUtils

    # Convert the provided object to the corresponding vim
    # representation. Complex types are not supported.
    def self.to_vim(object)
      if object.kind_of?(Hash)
        VimUtils.to_dictionary(object)
      elsif object.kind_of?(Array)
        VimUtils.to_vimarray(object)
      elsif object.kind_of?(Numeric)
        object
      else
        if object
          object.to_s.inspect
        else
          '""'
        end
      end
    end

    # Convert a hash object to the corresponding string representation 
    # of a vim dictionary. Complex hashes with complex types are not
    # supported as there's no corresponding vim type for them. These types
    # are converted to their string representation.
    def self.to_dictionary(hash)
      parts = []
      hash.each_key do |key|
        if hash[key].kind_of?(Hash)
          parts << VimUtils.to_dictionary(hash[key])
        elsif hash[key].kind_of?(Array)
          parts << "#{key.to_s.inspect} : #{VimUtils.to_vimarray(hash[key])}"
        elsif hash[key].kind_of?(Numeric)
          parts << "#{key.to_s.inspect} : #{hash[key]}"
        else
          parts << "#{key.to_s.inspect} : #{(hash[key] ? hash[key].inspect : '""')}"
        end
      end
      "{#{parts.join(',')}}"
    end

    # Convert an array object to the corresponding string representation 
    # of a vim dictionary. Complex arrays with complex types are not
    # supported as there's no corresponding vim type for them. These types
    # are converted to their string representation.
    def self.to_vimarray(array)
      parts = []
      array.each do |element|
        if element.kind_of?(Hash)
          parts << VimUtils.to_dictionary(element)
        elsif element.kind_of?(Numeric)
          parts << element
        elsif element.kind_of?(Array)
          parts << VimUtils.to_vimarray(element)
        else
          parts << (element ? element.to_s.inspect : '""')
        end
      end
      "[#{parts.join(',')}]"
    end

  end
end
