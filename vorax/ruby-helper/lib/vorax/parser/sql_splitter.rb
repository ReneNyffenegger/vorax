
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
#!/usr/bin/ragel -R

module Vorax

  module SqlSplitter

    
# line 43 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"


    
# line 15 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
class << self
	attr_accessor :_sqlsplitter_actions
	private :_sqlsplitter_actions, :_sqlsplitter_actions=
end
self._sqlsplitter_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9, 1, 10, 1, 
	11, 1, 12, 1, 13
]

class << self
	attr_accessor :_sqlsplitter_key_offsets
	private :_sqlsplitter_key_offsets, :_sqlsplitter_key_offsets=
end
self._sqlsplitter_key_offsets = [
	0, 1, 2, 5, 6, 8, 23, 26, 
	31, 34, 35, 36, 37, 41, 44, 45
]

class << self
	attr_accessor :_sqlsplitter_trans_keys
	private :_sqlsplitter_trans_keys, :_sqlsplitter_trans_keys=
end
self._sqlsplitter_trans_keys = [
	34, 39, 9, 32, 47, 42, 42, 47, 
	10, 32, 34, 39, 45, 47, 59, 9, 
	13, 48, 57, 65, 90, 97, 122, 32, 
	9, 13, 9, 32, 47, 10, 13, 9, 
	10, 32, 34, 39, 45, 9, 10, 32, 
	47, 9, 32, 47, 42, 48, 57, 65, 
	90, 97, 122, 0
]

class << self
	attr_accessor :_sqlsplitter_single_lengths
	private :_sqlsplitter_single_lengths, :_sqlsplitter_single_lengths=
end
self._sqlsplitter_single_lengths = [
	1, 1, 3, 1, 2, 7, 1, 3, 
	3, 1, 1, 1, 4, 3, 1, 0
]

class << self
	attr_accessor :_sqlsplitter_range_lengths
	private :_sqlsplitter_range_lengths, :_sqlsplitter_range_lengths=
end
self._sqlsplitter_range_lengths = [
	0, 0, 0, 0, 0, 4, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 3
]

class << self
	attr_accessor :_sqlsplitter_index_offsets
	private :_sqlsplitter_index_offsets, :_sqlsplitter_index_offsets=
end
self._sqlsplitter_index_offsets = [
	0, 2, 4, 8, 10, 13, 25, 28, 
	33, 37, 39, 41, 43, 48, 52, 54
]

class << self
	attr_accessor :_sqlsplitter_indicies
	private :_sqlsplitter_indicies, :_sqlsplitter_indicies=
end
self._sqlsplitter_indicies = [
	2, 1, 4, 3, 6, 6, 7, 5, 
	9, 8, 9, 10, 8, 13, 12, 14, 
	15, 16, 17, 19, 12, 18, 18, 18, 
	11, 12, 12, 20, 13, 13, 7, 12, 
	20, 7, 19, 7, 21, 2, 1, 4, 
	3, 23, 22, 6, 25, 6, 7, 23, 
	6, 6, 7, 24, 8, 22, 18, 18, 
	18, 20, 0
]

class << self
	attr_accessor :_sqlsplitter_trans_targs
	private :_sqlsplitter_trans_targs, :_sqlsplitter_trans_targs=
end
self._sqlsplitter_trans_targs = [
	5, 0, 5, 1, 5, 5, 2, 8, 
	3, 4, 5, 5, 6, 7, 9, 10, 
	11, 14, 15, 5, 5, 5, 5, 12, 
	5, 13
]

class << self
	attr_accessor :_sqlsplitter_trans_actions
	private :_sqlsplitter_trans_actions, :_sqlsplitter_trans_actions=
end
self._sqlsplitter_trans_actions = [
	27, 0, 9, 0, 7, 25, 0, 0, 
	0, 0, 11, 15, 0, 0, 5, 5, 
	0, 5, 0, 13, 21, 19, 23, 5, 
	17, 5
]

class << self
	attr_accessor :_sqlsplitter_to_state_actions
	private :_sqlsplitter_to_state_actions, :_sqlsplitter_to_state_actions=
end
self._sqlsplitter_to_state_actions = [
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_sqlsplitter_from_state_actions
	private :_sqlsplitter_from_state_actions, :_sqlsplitter_from_state_actions=
end
self._sqlsplitter_from_state_actions = [
	0, 0, 0, 0, 0, 3, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_sqlsplitter_eof_trans
	private :_sqlsplitter_eof_trans, :_sqlsplitter_eof_trans=
end
self._sqlsplitter_eof_trans = [
	1, 1, 6, 1, 1, 0, 21, 21, 
	22, 23, 23, 23, 25, 25, 23, 21
]

class << self
	attr_accessor :sqlsplitter_start
end
self.sqlsplitter_start = 5;
class << self
	attr_accessor :sqlsplitter_first_final
end
self.sqlsplitter_first_final = 5;
class << self
	attr_accessor :sqlsplitter_error
end
self.sqlsplitter_error = -1;

class << self
	attr_accessor :sqlsplitter_en_main
end
self.sqlsplitter_en_main = 5;


# line 46 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"

    def SqlSplitter.split(data)
      # convert the provided string in a stream of chars
      stream_data = data.unpack("c*") if(data.is_a?(String))
      eof = stream_data.length
      # the array with separator markers. The beginning of the
      # string is always considered a marker.
      @markers = [0]
            
      
# line 171 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = sqlsplitter_start
	ts = nil
	te = nil
	act = 0
end

# line 56 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
      
# line 183 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	end
	if _goto_level <= _resume
	_acts = _sqlsplitter_from_state_actions[cs]
	_nacts = _sqlsplitter_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _sqlsplitter_actions[_acts - 1]
			when 1 then
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
ts = p
		end
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
# line 214 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _sqlsplitter_key_offsets[cs]
	_trans = _sqlsplitter_index_offsets[cs]
	_klen = _sqlsplitter_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p] < _sqlsplitter_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p] > _sqlsplitter_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _sqlsplitter_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p] < _sqlsplitter_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p] > _sqlsplitter_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	_trans = _sqlsplitter_indicies[_trans]
	end
	if _goto_level <= _eof_trans
	cs = _sqlsplitter_trans_targs[_trans]
	if _sqlsplitter_trans_actions[_trans] != 0
		_acts = _sqlsplitter_trans_actions[_trans]
		_nacts = _sqlsplitter_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _sqlsplitter_actions[_acts - 1]
when 2 then
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
		end
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 3 then
# line 34 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
		end
# line 34 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 4 then
# line 35 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
		end
# line 35 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 5 then
# line 36 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
		end
# line 36 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 6 then
# line 38 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
 begin  @markers << te  end
		end
# line 38 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 7 then
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p+1
		end
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 8 then
# line 37 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p
p = p - 1;		end
# line 37 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 9 then
# line 38 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p
p = p - 1; begin  @markers << te  end
		end
# line 38 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 10 then
# line 39 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p
p = p - 1;		end
# line 39 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 11 then
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
te = p
p = p - 1;		end
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 12 then
# line 37 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
 begin p = ((te))-1; end
		end
# line 37 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
when 13 then
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
 begin p = ((te))-1; end
		end
# line 40 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
# line 355 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _sqlsplitter_to_state_actions[cs]
	_nacts = _sqlsplitter_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _sqlsplitter_actions[_acts - 1]
when 0 then
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
		begin
ts = nil;		end
# line 1 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"
# line 376 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _sqlsplitter_eof_trans[cs] > 0
		_trans = _sqlsplitter_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 57 "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/sql_splitter.rl"

      # add the end marker as the end of the string
      @markers << eof unless @markers.include?(eof)

      # split into statements now
      statements = []
      0.upto(@markers.length-2) do |index|
        statements << data[(@markers[index] ... @markers[index+1])]
      end
      # remove the last statement if it's comprised of whitespace only
      statements.delete_at(-1) if statements.last =~ /\A[ \t\r\n]*\Z/
      statements
    end

  end

end
