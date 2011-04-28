$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'vorax'
require 'test/unit'
require 'tmpdir'

include Vorax

TEST_DATABASE = 'poc'
TEST_USER = 'talek'
TEST_USER_PWD = 'muci'

class << Test::Unit::TestCase

  def is_windows?
     RUBY_PLATFORM.downcase.include?("mswin") ||
       RUBY_PLATFORM.downcase.include?("mingw")
  end

  def is_linux?
     RUBY_PLATFORM.downcase.include?("linux")
  end

end
