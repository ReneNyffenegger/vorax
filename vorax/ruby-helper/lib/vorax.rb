#!/usr/bin/ruby

$KCODE = 'UTF-8' 

require 'rubygems'
require 'nokogiri'
require 'encoding/character/utf-8'

require 'vorax/utils/ring_buffer.rb'
require 'vorax/utils/vim_utils.rb'
require 'vorax/process/generic_process.rb'
require 'vorax/process/unix_process.rb'
require 'vorax/process/windows_process.rb'
require 'vorax/process/sqlplus.rb'
require 'vorax/profile/profiles_manager.rb'
require 'vorax/sqlhtml/sql_html_beautifier.rb'

