#!/usr/bin/ruby

$KCODE = 'UTF-8' 

require 'rubygems'
require 'nokogiri'
require 'encoding/character/utf-8'
require 'antlr3'

module Vorax

  def Vorax.source(file, force = (defined?($vorax_testing) && $vorax_testing))
    if force
      load file
    else
      require file
    end
  end

end

Vorax::source('vorax/utils/ring_buffer.rb')
Vorax::source('vorax/utils/vim_utils.rb')
Vorax::source('vorax/process/generic_process.rb')
Vorax::source('vorax/process/unix_process.rb')
Vorax::source('vorax/process/windows_process.rb')
Vorax::source('vorax/process/sqlplus.rb')
Vorax::source('vorax/profile/profiles_manager.rb')
Vorax::source('vorax/sqlhtml/sql_html_beautifier.rb')

# load grammars
Vorax::source('vorax/parser/SqlSplitter.rb')

