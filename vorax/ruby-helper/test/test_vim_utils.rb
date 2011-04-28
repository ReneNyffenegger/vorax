#!/usr/bin/ruby

require 'test/common'

class TestVimUtils < Test::Unit::TestCase

  def test_to_dictionary
    assert VimUtils.to_dictionary({ :muci => 'abc', :buci => 2 }) == %!{"muci" : "abc","buci" : 2}! 
    assert VimUtils.to_dictionary({:muci => 'abc', :hash => {:e1 => 'x', :e2 => 'y'}}) == "{\"muci\" : \"abc\",{\"e1\" : \"x\",\"e2\" : \"y\"}}"
    assert VimUtils.to_dictionary({:muci => 'abc', :hash => {:e1 => 'x', :e2 => 'y'}, :array => [1, 'b', 4]}) == '{"muci" : "abc",{"e1" : "x","e2" : "y"},"array" : [1,"b",4]}'
  end

  def test_to_array
    assert VimUtils.to_vimarray(['abc', [1, '2', 3]]) == '["abc",[1,"2",3]]'
    assert VimUtils.to_vimarray(['abc', {:k1 => 1, :k2 => 2}]) == '["abc",{"k1" : 1,"k2" : 2}]'
  end

  def test_to_vim
    assert VimUtils.to_vim([1, 2, ['a', 'b'], {:x => 'muci', :y => 'buci'}]) == '[1,2,["a","b"],{"x" : "muci","y" : "buci"}]'
  end

end
