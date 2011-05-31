#!/usr/bin/env ruby
#
# vorax/ruby-helper/grammar/SqlSplitter.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: vorax/ruby-helper/grammar/SqlSplitter.ruby.g
# Generated at: 2011-05-30 16:44:34
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


module SqlSplitter
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all 
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :ML_COMMENT => 6, :SQL_SEPARATOR_2 => 8, :SQL_SEPARATOR_1 => 7, 
                   :WS => 12, :SQL_SEPARATOR => 9, :SL_COMMENT => 5, :QUOTED_STRING => 4, 
                   :SPACE => 11, :CR => 10, :EOF => -1 )
    
  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = SqlSplitter
    include TokenData
    include ANTLR3::FilterMode

    
    begin
      generated_using( "vorax/ruby-helper/grammar/SqlSplitter.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "QUOTED_STRING", "SL_COMMENT", "ML_COMMENT", "SQL_SEPARATOR", 
                     "SQL_SEPARATOR_1", "SQL_SEPARATOR_2", "CR", "SPACE", 
                     "WS" ].freeze
    RULE_METHODS = [ :quoted_string!, :sl_comment!, :ml_comment!, :sql_separator!, 
                     :sql_separator_1!, :sql_separator_2!, :cr!, :space!, 
                     :ws! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )
      # - - - - - - begin action @lexer::init - - - - - -
      # vorax/ruby-helper/grammar/SqlSplitter.ruby.g


      	@separators = []

      # - - - - - - end action @lexer::init - - - - - - -

    end
    
    # - - - - - - begin action @lexer::members - - - - - -
    # vorax/ruby-helper/grammar/SqlSplitter.ruby.g



    	attr_accessor :separators

      def self.split(text)
        unless text.empty?
          input = ANTLR3::StringStream.new(text)
          lexer = SqlSplitter::Lexer.new(input)
          lexer.map
          statements = []
          last_pos = 0
          lexer.separators << text.length if lexer.separators == [] || lexer.separators.last < text.length
          lexer.separators.each do |pos|
            statements << text[(last_pos ... pos)]
            last_pos = pos
          end
          statements
        else
        	return []
        end
      end

      private

      def mark_this(marker)
        @separators << (marker.stop + 1)
      end


    # - - - - - - end action @lexer::members - - - - - - -

    
    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule quoted_string! (QUOTED_STRING)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def quoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = QUOTED_STRING
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 45:5: ( 'n' )? '\\'' ( '\\'\\'' | ~ ( '\\'' ) )* '\\''
      # at line 45:5: ( 'n' )?
      alt_1 = 2
      look_1_0 = @input.peek( 1 )

      if ( look_1_0 == 0x6e )
        alt_1 = 1
      end
      case alt_1
      when 1
        # at line 45:7: 'n'
        match( 0x6e )

      end
      match( 0x27 )
      # at line 45:19: ( '\\'\\'' | ~ ( '\\'' ) )*
      while true # decision 2
        alt_2 = 3
        look_2_0 = @input.peek( 1 )

        if ( look_2_0 == 0x27 )
          look_2_1 = @input.peek( 2 )

          if ( look_2_1 == 0x27 )
            alt_2 = 1

          end
        elsif ( look_2_0.between?( 0x0, 0x26 ) || look_2_0.between?( 0x28, 0xffff ) )
          alt_2 = 2

        end
        case alt_2
        when 1
          # at line 45:21: '\\'\\''
          match( "''" )

        when 2
          # at line 45:30: ~ ( '\\'' )
          if @input.peek( 1 ).between?( 0x0, 0x26 ) || @input.peek( 1 ).between?( 0x28, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 2
        end
      end # loop for decision 2
      match( 0x27 )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 1 )

    end

    # lexer rule sl_comment! (SL_COMMENT)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def sl_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = SL_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 49:5: '--' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? ( '\\n' | EOF )
      match( "--" )
      # at line 49:10: (~ ( '\\n' | '\\r' ) )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( 0x0, 0x9 ) || look_3_0.between?( 0xb, 0xc ) || look_3_0.between?( 0xe, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 49:10: ~ ( '\\n' | '\\r' )
          if @input.peek( 1 ).between?( 0x0, 0x9 ) || @input.peek( 1 ).between?( 0xb, 0xc ) || @input.peek( 1 ).between?( 0xe, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 3
        end
      end # loop for decision 3
      # at line 49:24: ( '\\r' )?
      alt_4 = 2
      look_4_0 = @input.peek( 1 )

      if ( look_4_0 == 0xd )
        alt_4 = 1
      end
      case alt_4
      when 1
        # at line 49:24: '\\r'
        match( 0xd )

      end
      # at line 49:30: ( '\\n' | EOF )
      alt_5 = 2
      look_5_0 = @input.peek( 1 )

      if ( look_5_0 == 0xa )
        alt_5 = 1
      else
        alt_5 = 2
      end
      case alt_5
      when 1
        # at line 49:31: '\\n'
        match( 0xa )

      when 2
        # at line 49:38: EOF
        match( ANTLR3::EOF )


      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 2 )

    end

    # lexer rule ml_comment! (ML_COMMENT)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def ml_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = ML_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 53:5: '/*' ( options {greedy=false; } : . )* '*/'
      match( "/*" )
      # at line 53:10: ( options {greedy=false; } : . )*
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
          # at line 53:38: .
          match_any

        else
          break # out of loop for decision 6
        end
      end # loop for decision 6
      match( "*/" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 3 )

    end

    # lexer rule sql_separator! (SQL_SEPARATOR)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def sql_separator!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = SQL_SEPARATOR
      channel = ANTLR3::DEFAULT_CHANNEL
      # - - - - label initialization - - - -
      __SQL_SEPARATOR_11__ = nil
      __SQL_SEPARATOR_22__ = nil


      
      # - - - - main rule block - - - -
      # at line 57:3: ( SQL_SEPARATOR_1 | SQL_SEPARATOR_2 )
      alt_7 = 2
      look_7_0 = @input.peek( 1 )

      if ( look_7_0 == 0x3b )
        alt_7 = 1
      elsif ( look_7_0 == 0xa )
        alt_7 = 2
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 7, 0 )
      end
      case alt_7
      when 1
        # at line 57:5: SQL_SEPARATOR_1
        __SQL_SEPARATOR_11___start_150 = self.character_index
        sql_separator_1!
        __SQL_SEPARATOR_11__ = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = __SQL_SEPARATOR_11___start_150
          t.stop    = self.character_index - 1
        end
        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action
           mark_this(__SQL_SEPARATOR_11__) 
          # <-- action
        end

      when 2
        # at line 59:5: SQL_SEPARATOR_2
        __SQL_SEPARATOR_22___start_165 = self.character_index
        sql_separator_2!
        __SQL_SEPARATOR_22__ = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = __SQL_SEPARATOR_22___start_165
          t.stop    = self.character_index - 1
        end
        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action
           mark_this(__SQL_SEPARATOR_22__) 
          # <-- action
        end

      end
      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )

    end

    # lexer rule sql_separator_1! (SQL_SEPARATOR_1)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def sql_separator_1!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      
      # - - - - main rule block - - - -
      # at line 64:5: ';'
      match( 0x3b )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )

    end

    # lexer rule sql_separator_2! (SQL_SEPARATOR_2)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def sql_separator_2!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      
      # - - - - main rule block - - - -
      # at line 69:5: CR ( SPACE )* '/' ( SPACE )* ( CR | EOF )
      cr!
      # at line 69:9: ( SPACE )*
      while true # decision 8
        alt_8 = 2
        look_8_0 = @input.peek( 1 )

        if ( look_8_0 == 0x9 || look_8_0 == 0x20 )
          alt_8 = 1

        end
        case alt_8
        when 1
          # at line 69:9: SPACE
          space!

        else
          break # out of loop for decision 8
        end
      end # loop for decision 8
      match( 0x2f )
      # at line 69:20: ( SPACE )*
      while true # decision 9
        alt_9 = 2
        look_9_0 = @input.peek( 1 )

        if ( look_9_0 == 0x9 || look_9_0 == 0x20 )
          alt_9 = 1

        end
        case alt_9
        when 1
          # at line 69:20: SPACE
          space!

        else
          break # out of loop for decision 9
        end
      end # loop for decision 9
      # at line 69:27: ( CR | EOF )
      alt_10 = 2
      look_10_0 = @input.peek( 1 )

      if ( look_10_0 == 0xa )
        alt_10 = 1
      else
        alt_10 = 2
      end
      case alt_10
      when 1
        # at line 69:28: CR
        cr!

      when 2
        # at line 69:33: EOF
        match( ANTLR3::EOF )


      end

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )

    end

    # lexer rule cr! (CR)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def cr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      
      # - - - - main rule block - - - -
      # at line 74:5: ( '\\n' )+
      # at file 74:5: ( '\\n' )+
      match_count_11 = 0
      while true
        alt_11 = 2
        look_11_0 = @input.peek( 1 )

        if ( look_11_0 == 0xa )
          alt_11 = 1

        end
        case alt_11
        when 1
          # at line 74:5: '\\n'
          match( 0xa )

        else
          match_count_11 > 0 and break
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          eee = EarlyExit(11)


          raise eee
        end
        match_count_11 += 1
      end


    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule space! (SPACE)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def space!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      
      # - - - - main rule block - - - -
      # at line 79:5: ( ' ' | '\\t' )+
      # at file 79:5: ( ' ' | '\\t' )+
      match_count_12 = 0
      while true
        alt_12 = 2
        look_12_0 = @input.peek( 1 )

        if ( look_12_0 == 0x9 || look_12_0 == 0x20 )
          alt_12 = 1

        end
        case alt_12
        when 1
          # at line 
          if @input.peek(1) == 0x9 || @input.peek(1) == 0x20
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          match_count_12 > 0 and break
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          eee = EarlyExit(12)


          raise eee
        end
        match_count_12 += 1
      end


    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )

    end

    # lexer rule ws! (WS)
    # (in vorax/ruby-helper/grammar/SqlSplitter.ruby.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      
      # - - - - main rule block - - - -
      # at line 84:5: ( ' ' | '\\t' | '\\n' )+
      # at file 84:5: ( ' ' | '\\t' | '\\n' )+
      match_count_13 = 0
      while true
        alt_13 = 2
        look_13_0 = @input.peek( 1 )

        if ( look_13_0.between?( 0x9, 0xa ) || look_13_0 == 0x20 )
          alt_13 = 1

        end
        case alt_13
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x9, 0xa ) || @input.peek(1) == 0x20
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          match_count_13 > 0 and break
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          eee = EarlyExit(13)


          raise eee
        end
        match_count_13 += 1
      end


    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # main rule used to study the input at the current position,
    # and choose the proper lexer rule to call in order to
    # fetch the next token
    # 
    # usually, you don't make direct calls to this method,
    # but instead use the next_token method, which will
    # build and emit the actual next token
    def token!
      # at line 1:39: ( QUOTED_STRING | SL_COMMENT | ML_COMMENT | SQL_SEPARATOR )
      alt_14 = 4
      case look_14 = @input.peek( 1 )
      when 0x27, 0x6e then alt_14 = 1
      when 0x2d then alt_14 = 2
      when 0x2f then alt_14 = 3
      when 0xa, 0x3b then alt_14 = 4
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 14, 0 )
      end
      case alt_14
      when 1
        # at line 1:41: QUOTED_STRING
        quoted_string!

      when 2
        # at line 1:55: SL_COMMENT
        sl_comment!

      when 3
        # at line 1:66: ML_COMMENT
        ml_comment!

      when 4
        # at line 1:77: SQL_SEPARATOR
        sql_separator!

      end
    end

  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end

