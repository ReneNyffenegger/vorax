#!/usr/bin/env ruby
#
# orasource.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: orasource.ruby.g
# Generated at: 2011-10-17 09:51:33
# 

# ~~~> start load path setup
this_directory = File.expand_path( File.dirname( __FILE__ ) )
$LOAD_PATH.unshift( this_directory ) unless $LOAD_PATH.include?( this_directory )

antlr_load_failed = proc do
  load_path = $LOAD_PATH.map { |dir| '  - ' << dir }.join( $/ )
  raise LoadError, <<-END.strip!
  
Failed to load the ANTLR3 runtime library (version 1.8.11):

Ensure the library has been installed on your system and is available
on the load path. If rubygems is available on your system, this can
be done with the command:
  
  gem install antlr3

Current load path:
#{ load_path }

  END
end

defined?( ANTLR3 ) or begin
  
  # 1: try to load the ruby antlr3 runtime library from the system path
  require 'antlr3'
  
rescue LoadError
  
  # 2: try to load rubygems if it isn't already loaded
  defined?( Gem ) or begin
    require 'rubygems'
  rescue LoadError
    antlr_load_failed.call
  end
  
  # 3: try to activate the antlr3 gem
  begin
    Gem.activate( 'antlr3', '~> 1.8.11' )
  rescue Gem::LoadError
    antlr_load_failed.call
  end
  
  require 'antlr3'
  
end
# <~~~ end load path setup

# - - - - - - begin action @all::header - - - - - -
# orasource.ruby.g


	module Vorax 

# - - - - - - end action @all::header - - - - - - -


module Orasource
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all 
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :POINT => 10, :DOUBLEQUOTED_STRING => 6, :T__20 => 20, 
                   :ID => 5, :EOF => -1, :T__19 => 19, :ML_COMMENT => 9, 
                   :T__16 => 16, :WS => 7, :T__15 => 15, :T__18 => 18, :T__17 => 17, 
                   :T__12 => 12, :T__11 => 11, :T__14 => 14, :T__13 => 13, 
                   :SL_COMMENT => 8, :DOT => 4 )
    
  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = Orasource
    include TokenData

    
    begin
      generated_using( "orasource.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "T__11", "T__12", "T__13", "T__14", "T__15", "T__16", 
                     "T__17", "T__18", "T__19", "T__20", "ID", "DOUBLEQUOTED_STRING", 
                     "WS", "SL_COMMENT", "ML_COMMENT", "DOT", "POINT" ].freeze
    RULE_METHODS = [ :t__11!, :t__12!, :t__13!, :t__14!, :t__15!, :t__16!, 
                     :t__17!, :t__18!, :t__19!, :t__20!, :id!, :doublequoted_string!, 
                     :ws!, :sl_comment!, :ml_comment!, :dot!, :point! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )

    end
    
    
    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule t__11! (T__11)
    # (in orasource.ruby.g)
    def t__11!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = T__11
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 7:9: 'CREATE'
      match( "CREATE" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 1 )

    end

    # lexer rule t__12! (T__12)
    # (in orasource.ruby.g)
    def t__12!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = T__12
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 8:9: 'OR'
      match( "OR" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 2 )

    end

    # lexer rule t__13! (T__13)
    # (in orasource.ruby.g)
    def t__13!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = T__13
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 9:9: 'PACKAGE'
      match( "PACKAGE" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 3 )

    end

    # lexer rule t__14! (T__14)
    # (in orasource.ruby.g)
    def t__14!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = T__14
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 10:9: 'IS'
      match( "IS" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )

    end

    # lexer rule t__15! (T__15)
    # (in orasource.ruby.g)
    def t__15!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      type = T__15
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 11:9: 'AS'
      match( "AS" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )

    end

    # lexer rule t__16! (T__16)
    # (in orasource.ruby.g)
    def t__16!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      type = T__16
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 12:9: 'TYPE'
      match( "TYPE" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )

    end

    # lexer rule t__17! (T__17)
    # (in orasource.ruby.g)
    def t__17!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      type = T__17
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 13:9: 'TRIGGER'
      match( "TRIGGER" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule t__18! (T__18)
    # (in orasource.ruby.g)
    def t__18!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      type = T__18
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 14:9: 'PROCEDURE'
      match( "PROCEDURE" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )

    end

    # lexer rule t__19! (T__19)
    # (in orasource.ruby.g)
    def t__19!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      type = T__19
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 15:9: 'FUNCTION'
      match( "FUNCTION" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # lexer rule t__20! (T__20)
    # (in orasource.ruby.g)
    def t__20!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )

      type = T__20
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 16:9: 'VIEW'
      match( "VIEW" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 10 )

    end

    # lexer rule id! (ID)
    # (in orasource.ruby.g)
    def id!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )

      type = ID
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 122:5: ( 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )* | DOUBLEQUOTED_STRING )
      alt_2 = 2
      look_2_0 = @input.peek( 1 )

      if ( look_2_0.between?( 0x41, 0x5a ) )
        alt_2 = 1
      elsif ( look_2_0 == 0x22 )
        alt_2 = 2
      else
        raise NoViableAlternative( "", 2, 0 )
      end
      case alt_2
      when 1
        # at line 122:7: 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        match_range( 0x41, 0x5a )
        # at line 122:18: ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        while true # decision 1
          alt_1 = 2
          look_1_0 = @input.peek( 1 )

          if ( look_1_0.between?( 0x23, 0x24 ) || look_1_0.between?( 0x30, 0x39 ) || look_1_0.between?( 0x41, 0x5a ) || look_1_0 == 0x5f )
            alt_1 = 1

          end
          case alt_1
          when 1
            # at line 
            if @input.peek( 1 ).between?( 0x23, 0x24 ) || @input.peek( 1 ).between?( 0x30, 0x39 ) || @input.peek( 1 ).between?( 0x41, 0x5a ) || @input.peek(1) == 0x5f
              @input.consume
            else
              mse = MismatchedSet( nil )
              recover mse
              raise mse
            end



          else
            break # out of loop for decision 1
          end
        end # loop for decision 1

      when 2
        # at line 123:7: DOUBLEQUOTED_STRING
        doublequoted_string!

      end
      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 11 )

    end

    # lexer rule doublequoted_string! (DOUBLEQUOTED_STRING)
    # (in orasource.ruby.g)
    def doublequoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )

      
      # - - - - main rule block - - - -
      # at line 128:4: '\"' (~ ( '\"' ) )* '\"'
      match( 0x22 )
      # at line 128:8: (~ ( '\"' ) )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( 0x0, 0x21 ) || look_3_0.between?( 0x23, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 128:10: ~ ( '\"' )
          if @input.peek( 1 ).between?( 0x0, 0x21 ) || @input.peek( 1 ).between?( 0x23, 0xff )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 3
        end
      end # loop for decision 3
      match( 0x22 )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 12 )

    end

    # lexer rule ws! (WS)
    # (in orasource.ruby.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )

      type = WS
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 131:6: ( ' ' | '\\r' | '\\t' | '\\n' )
      if @input.peek( 1 ).between?( 0x9, 0xa ) || @input.peek(1) == 0xd || @input.peek(1) == 0x20
        @input.consume
      else
        mse = MismatchedSet( nil )
        recover mse
        raise mse
      end


      # --> action
      channel=HIDDEN;
      # <-- action

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 13 )

    end

    # lexer rule sl_comment! (SL_COMMENT)
    # (in orasource.ruby.g)
    def sl_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )

      type = SL_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 134:4: '--' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
      match( "--" )
      # at line 134:9: (~ ( '\\n' | '\\r' ) )*
      while true # decision 4
        alt_4 = 2
        look_4_0 = @input.peek( 1 )

        if ( look_4_0.between?( 0x0, 0x9 ) || look_4_0.between?( 0xb, 0xc ) || look_4_0.between?( 0xe, 0xffff ) )
          alt_4 = 1

        end
        case alt_4
        when 1
          # at line 134:9: ~ ( '\\n' | '\\r' )
          if @input.peek( 1 ).between?( 0x0, 0x9 ) || @input.peek( 1 ).between?( 0xb, 0xc ) || @input.peek( 1 ).between?( 0xe, 0xff )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 4
        end
      end # loop for decision 4
      # at line 134:23: ( '\\r' )?
      alt_5 = 2
      look_5_0 = @input.peek( 1 )

      if ( look_5_0 == 0xd )
        alt_5 = 1
      end
      case alt_5
      when 1
        # at line 134:23: '\\r'
        match( 0xd )

      end
      match( 0xa )
      # --> action
      channel=HIDDEN;
      # <-- action

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 14 )

    end

    # lexer rule ml_comment! (ML_COMMENT)
    # (in orasource.ruby.g)
    def ml_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )

      type = ML_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 137:4: '/*' ( options {greedy=false; } : . )* '*/'
      match( "/*" )
      # at line 137:9: ( options {greedy=false; } : . )*
      while true # decision 6
        alt_6 = 2
        look_6_0 = @input.peek( 1 )

        if ( look_6_0 == 0x2a )
          look_6_1 = @input.peek( 2 )

          if ( look_6_1 == 0x2f )
            alt_6 = 2
          elsif ( look_6_1.between?( 0x0, 0x2e ) || look_6_1.between?( 0x30, 0xffff ) )
            alt_6 = 1

          end
        elsif ( look_6_0.between?( 0x0, 0x29 ) || look_6_0.between?( 0x2b, 0xffff ) )
          alt_6 = 1

        end
        case alt_6
        when 1
          # at line 137:37: .
          match_any

        else
          break # out of loop for decision 6
        end
      end # loop for decision 6
      match( "*/" )
      # --> action
      channel=HIDDEN;
      # <-- action

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 15 )

    end

    # lexer rule dot! (DOT)
    # (in orasource.ruby.g)
    def dot!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )

      type = DOT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 141:4: POINT
      point!

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 16 )

    end

    # lexer rule point! (POINT)
    # (in orasource.ruby.g)
    def point!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 17 )

      
      # - - - - main rule block - - - -
      # at line 146:4: '.'
      match( 0x2e )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 17 )

    end

    # main rule used to study the input at the current position,
    # and choose the proper lexer rule to call in order to
    # fetch the next token
    # 
    # usually, you don't make direct calls to this method,
    # but instead use the next_token method, which will
    # build and emit the actual next token
    def token!
      # at line 1:8: ( T__11 | T__12 | T__13 | T__14 | T__15 | T__16 | T__17 | T__18 | T__19 | T__20 | ID | WS | SL_COMMENT | ML_COMMENT | DOT )
      alt_7 = 15
      alt_7 = @dfa7.predict( @input )
      case alt_7
      when 1
        # at line 1:10: T__11
        t__11!

      when 2
        # at line 1:16: T__12
        t__12!

      when 3
        # at line 1:22: T__13
        t__13!

      when 4
        # at line 1:28: T__14
        t__14!

      when 5
        # at line 1:34: T__15
        t__15!

      when 6
        # at line 1:40: T__16
        t__16!

      when 7
        # at line 1:46: T__17
        t__17!

      when 8
        # at line 1:52: T__18
        t__18!

      when 9
        # at line 1:58: T__19
        t__19!

      when 10
        # at line 1:64: T__20
        t__20!

      when 11
        # at line 1:70: ID
        id!

      when 12
        # at line 1:73: WS
        ws!

      when 13
        # at line 1:76: SL_COMMENT
        sl_comment!

      when 14
        # at line 1:87: ML_COMMENT
        ml_comment!

      when 15
        # at line 1:98: DOT
        dot!

      end
    end

    
    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA7 < ANTLR3::DFA
      EOT = unpack( 1, -1, 8, 9, 5, -1, 1, 9, 1, 25, 2, 9, 1, 28, 1, 29, 
                    5, 9, 1, -1, 2, 9, 2, -1, 7, 9, 1, 44, 2, 9, 1, 47, 
                    3, 9, 1, -1, 2, 9, 1, -1, 1, 53, 4, 9, 1, -1, 1, 58, 
                    1, 9, 1, 60, 1, 9, 1, -1, 1, 9, 1, -1, 1, 63, 1, 64, 
                    2, -1 )
      EOF = unpack( 65, -1 )
      MIN = unpack( 1, 9, 2, 82, 1, 65, 2, 83, 1, 82, 1, 85, 1, 73, 5, -1, 
                    1, 69, 1, 35, 1, 67, 1, 79, 2, 35, 1, 80, 1, 73, 1, 
                    78, 1, 69, 1, 65, 1, -1, 1, 75, 1, 67, 2, -1, 1, 69, 
                    1, 71, 1, 67, 1, 87, 1, 84, 1, 65, 1, 69, 1, 35, 1, 
                    71, 1, 84, 1, 35, 1, 69, 1, 71, 1, 68, 1, -1, 1, 69, 
                    1, 73, 1, -1, 1, 35, 1, 69, 1, 85, 1, 82, 1, 79, 1, 
                    -1, 1, 35, 1, 82, 1, 35, 1, 78, 1, -1, 1, 69, 1, -1, 
                    2, 35, 2, -1 )
      MAX = unpack( 1, 90, 3, 82, 2, 83, 1, 89, 1, 85, 1, 73, 5, -1, 1, 
                    69, 1, 95, 1, 67, 1, 79, 2, 95, 1, 80, 1, 73, 1, 78, 
                    1, 69, 1, 65, 1, -1, 1, 75, 1, 67, 2, -1, 1, 69, 1, 
                    71, 1, 67, 1, 87, 1, 84, 1, 65, 1, 69, 1, 95, 1, 71, 
                    1, 84, 1, 95, 1, 69, 1, 71, 1, 68, 1, -1, 1, 69, 1, 
                    73, 1, -1, 1, 95, 1, 69, 1, 85, 1, 82, 1, 79, 1, -1, 
                    1, 95, 1, 82, 1, 95, 1, 78, 1, -1, 1, 69, 1, -1, 2, 
                    95, 2, -1 )
      ACCEPT = unpack( 9, -1, 1, 11, 1, 12, 1, 13, 1, 14, 1, 15, 11, -1, 
                       1, 2, 2, -1, 1, 4, 1, 5, 14, -1, 1, 6, 2, -1, 1, 
                       10, 5, -1, 1, 1, 4, -1, 1, 3, 1, -1, 1, 7, 2, -1, 
                       1, 9, 1, 8 )
      SPECIAL = unpack( 65, -1 )
      TRANSITION = [
        unpack( 2, 10, 2, -1, 1, 10, 18, -1, 1, 10, 1, -1, 1, 9, 10, -1, 
                1, 11, 1, 13, 1, 12, 17, -1, 1, 5, 1, 9, 1, 1, 2, 9, 1, 
                7, 2, 9, 1, 4, 5, 9, 1, 2, 1, 3, 3, 9, 1, 6, 1, 9, 1, 8, 
                4, 9 ),
        unpack( 1, 14 ),
        unpack( 1, 15 ),
        unpack( 1, 16, 16, -1, 1, 17 ),
        unpack( 1, 18 ),
        unpack( 1, 19 ),
        unpack( 1, 21, 6, -1, 1, 20 ),
        unpack( 1, 22 ),
        unpack( 1, 23 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 24 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 26 ),
        unpack( 1, 27 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 30 ),
        unpack( 1, 31 ),
        unpack( 1, 32 ),
        unpack( 1, 33 ),
        unpack( 1, 34 ),
        unpack(  ),
        unpack( 1, 35 ),
        unpack( 1, 36 ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 37 ),
        unpack( 1, 38 ),
        unpack( 1, 39 ),
        unpack( 1, 40 ),
        unpack( 1, 41 ),
        unpack( 1, 42 ),
        unpack( 1, 43 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 45 ),
        unpack( 1, 46 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 48 ),
        unpack( 1, 49 ),
        unpack( 1, 50 ),
        unpack(  ),
        unpack( 1, 51 ),
        unpack( 1, 52 ),
        unpack(  ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 54 ),
        unpack( 1, 55 ),
        unpack( 1, 56 ),
        unpack( 1, 57 ),
        unpack(  ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 59 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 1, 61 ),
        unpack(  ),
        unpack( 1, 62 ),
        unpack(  ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack( 2, 9, 11, -1, 10, 9, 7, -1, 26, 9, 4, -1, 1, 9 ),
        unpack(  ),
        unpack(  )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 7
      

      def description
        <<-'__dfa_description__'.strip!
          1:1: Tokens : ( T__11 | T__12 | T__13 | T__14 | T__15 | T__16 | T__17 | T__18 | T__19 | T__20 | ID | WS | SL_COMMENT | ML_COMMENT | DOT );
        __dfa_description__
      end
    end

    
    private
    
    def initialize_dfas
      super rescue nil
      @dfa7 = DFA7.new( self, 7 )

    end
  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end
# - - - - - - begin action @all::footer - - - - - -
# orasource.ruby.g


	end

# - - - - - - end action @all::footer - - - - - - -


