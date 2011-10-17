#!/usr/bin/env ruby
#
# argument.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: argument.ruby.g
# Generated at: 2011-10-17 09:51:25
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
# argument.ruby.g


	module Vorax 

# - - - - - - end action @all::header - - - - - - -


module Argument
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all 
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :START_PROC => 9, :ML_COMMENT => 6, :EXPR => 11, :WS => 8, 
                   :DOUBLEQUOTED_STRING => 16, :PLSQL_MODULE => 10, :SL_COMMENT => 5, 
                   :QUOTED_STRING => 4, :END_FUNC => 15, :PARAM_DELIM => 13, 
                   :ID => 7, :EOF => -1, :CEXPR => 12, :START_ARGUMENT => 14 )
    
  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = Argument
    include TokenData
    include ANTLR3::FilterMode

    
    begin
      generated_using( "argument.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "QUOTED_STRING", "SL_COMMENT", "ML_COMMENT", "PLSQL_MODULE", 
                     "START_PROC", "CEXPR", "PARAM_DELIM", "EXPR", "START_ARGUMENT", 
                     "END_FUNC", "WS", "ID", "DOUBLEQUOTED_STRING" ].freeze
    RULE_METHODS = [ :quoted_string!, :sl_comment!, :ml_comment!, :plsql_module!, 
                     :start_proc!, :cexpr!, :param_delim!, :expr!, :start_argument!, 
                     :end_func!, :ws!, :id!, :doublequoted_string! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )
      # - - - - - - begin action @lexer::init - - - - - -
      # argument.ruby.g


        @pmodules = []
        @open = false
        @stack = []
        @parent = -1

      # - - - - - - end action @lexer::init - - - - - - -

    end
    
    # - - - - - - begin action @lexer::members - - - - - -
    # argument.ruby.g



      attr_reader :pmodules
      private
      ArgItem = Struct.new(:pos, :expr)

      def self.arguments_for(stmt, cpos)
        input = ANTLR3::StringStream.new(stmt.upcase)
        lexer = Argument::Lexer.new(input)
        lexer.map
        lexer.pmodules.each do |m|
          m[:args].each do |a|
            if a.pos.include?(cpos) && a.expr.nil?
              return m[:name]
            elsif a.pos.include?(cpos) && !a.expr.nil?
              return self.arguments_for(a.expr.gsub(/^\(|\)$/, ' '), cpos - a.pos.first)
            end
          end
        end
        nil
      end


    # - - - - - - end action @lexer::members - - - - - - -

    
    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule quoted_string! (QUOTED_STRING)
    # (in argument.ruby.g)
    def quoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = QUOTED_STRING
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 48:5: ( 'n' )? '\\'' ( '\\'\\'' | ~ ( '\\'' ) )* '\\''
      # at line 48:5: ( 'n' )?
      alt_1 = 2
      look_1_0 = @input.peek( 1 )

      if ( look_1_0 == 0x6e )
        alt_1 = 1
      end
      case alt_1
      when 1
        # at line 48:7: 'n'
        match( 0x6e )

      end
      match( 0x27 )
      # at line 48:19: ( '\\'\\'' | ~ ( '\\'' ) )*
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
          # at line 48:21: '\\'\\''
          match( "''" )

        when 2
          # at line 48:30: ~ ( '\\'' )
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
    # (in argument.ruby.g)
    def sl_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = SL_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 52:5: '--' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
      match( "--" )
      # at line 52:10: (~ ( '\\n' | '\\r' ) )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( 0x0, 0x9 ) || look_3_0.between?( 0xb, 0xc ) || look_3_0.between?( 0xe, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 52:10: ~ ( '\\n' | '\\r' )
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
      # at line 52:24: ( '\\r' )?
      alt_4 = 2
      look_4_0 = @input.peek( 1 )

      if ( look_4_0 == 0xd )
        alt_4 = 1
      end
      case alt_4
      when 1
        # at line 52:24: '\\r'
        match( 0xd )

      end
      match( 0xa )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 2 )

    end

    # lexer rule ml_comment! (ML_COMMENT)
    # (in argument.ruby.g)
    def ml_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = ML_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 56:5: '/*' ( options {greedy=false; } : . )* '*/'
      match( "/*" )
      # at line 56:10: ( options {greedy=false; } : . )*
      while true # decision 5
        alt_5 = 2
        look_5_0 = @input.peek( 1 )

        if ( look_5_0 == 0x2a )
          look_5_1 = @input.peek( 2 )

          if ( look_5_1 == 0x2f )
            alt_5 = 2
          elsif ( look_5_1.between?( 0x0, 0x2e ) || look_5_1.between?( 0x30, 0xffff ) )
            alt_5 = 1

          end
        elsif ( look_5_0.between?( 0x0, 0x29 ) || look_5_0.between?( 0x2b, 0xffff ) )
          alt_5 = 1

        end
        case alt_5
        when 1
          # at line 56:38: .
          match_any

        else
          break # out of loop for decision 5
        end
      end # loop for decision 5
      match( "*/" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 3 )

    end

    # lexer rule plsql_module! (PLSQL_MODULE)
    # (in argument.ruby.g)
    def plsql_module!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = PLSQL_MODULE
      channel = ANTLR3::DEFAULT_CHANNEL
      # - - - - label initialization - - - -
      tk1 = nil
      tk2 = nil
      tk3 = nil
      p = nil
      __ID1__ = nil


      
      # - - - - main rule block - - - -
      # at line 60:3: ( (tk1= ID '.' tk2= ID '.' tk3= ID ( WS )? p= START_PROC ) | (tk1= ID '.' tk2= ID ( WS )? p= START_PROC ) | ( ID ( WS )? p= START_PROC ) )
      alt_9 = 3
      alt_9 = @dfa9.predict( @input )
      case alt_9
      when 1
        # at line 60:5: (tk1= ID '.' tk2= ID '.' tk3= ID ( WS )? p= START_PROC )
        # at line 60:5: (tk1= ID '.' tk2= ID '.' tk3= ID ( WS )? p= START_PROC )
        # at line 60:6: tk1= ID '.' tk2= ID '.' tk3= ID ( WS )? p= START_PROC
        tk1_start_173 = self.character_index
        id!
        tk1 = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = tk1_start_173
          t.stop    = self.character_index - 1
        end
        match( 0x2e )
        tk2_start_179 = self.character_index
        id!
        tk2 = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = tk2_start_179
          t.stop    = self.character_index - 1
        end
        match( 0x2e )
        tk3_start_185 = self.character_index
        id!
        tk3 = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = tk3_start_185
          t.stop    = self.character_index - 1
        end
        # at line 60:35: ( WS )?
        alt_6 = 2
        look_6_0 = @input.peek( 1 )

        if ( look_6_0.between?( 0x9, 0xa ) || look_6_0 == 0x20 )
          alt_6 = 1
        end
        case alt_6
        when 1
          # at line 60:35: WS
          ws!

        end
        p_start_192 = self.character_index
        start_proc!
        p = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = p_start_192
          t.stop    = self.character_index - 1
        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action
           @pmodules << {:name => tk1.text + '.' + tk2.text + '.' + tk3.text, :args => [ArgItem.new(p.start + 1 .. p.stop + 1, nil)] } ; @parent += 1 
          # <-- action
        end

      when 2
        # at line 62:5: (tk1= ID '.' tk2= ID ( WS )? p= START_PROC )
        # at line 62:5: (tk1= ID '.' tk2= ID ( WS )? p= START_PROC )
        # at line 62:6: tk1= ID '.' tk2= ID ( WS )? p= START_PROC
        tk1_start_206 = self.character_index
        id!
        tk1 = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = tk1_start_206
          t.stop    = self.character_index - 1
        end
        match( 0x2e )
        tk2_start_212 = self.character_index
        id!
        tk2 = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = tk2_start_212
          t.stop    = self.character_index - 1
        end
        # at line 62:24: ( WS )?
        alt_7 = 2
        look_7_0 = @input.peek( 1 )

        if ( look_7_0.between?( 0x9, 0xa ) || look_7_0 == 0x20 )
          alt_7 = 1
        end
        case alt_7
        when 1
          # at line 62:24: WS
          ws!

        end
        p_start_219 = self.character_index
        start_proc!
        p = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = p_start_219
          t.stop    = self.character_index - 1
        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action
           @pmodules << {:name => tk1.text + '.' + tk2.text, :args => [ArgItem.new(p.start + 1 .. (p.stop + 1), nil)] } ; @parent += 1 
          # <-- action
        end

      when 3
        # at line 64:5: ( ID ( WS )? p= START_PROC )
        # at line 64:5: ( ID ( WS )? p= START_PROC )
        # at line 64:6: ID ( WS )? p= START_PROC
        __ID1___start_231 = self.character_index
        id!
        __ID1__ = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = __ID1___start_231
          t.stop    = self.character_index - 1
        end
        # at line 64:9: ( WS )?
        alt_8 = 2
        look_8_0 = @input.peek( 1 )

        if ( look_8_0.between?( 0x9, 0xa ) || look_8_0 == 0x20 )
          alt_8 = 1
        end
        case alt_8
        when 1
          # at line 64:9: WS
          ws!

        end
        p_start_238 = self.character_index
        start_proc!
        p = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = p_start_238
          t.stop    = self.character_index - 1
        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action
           @pmodules << {:name => __ID1__.text, :args => [ArgItem.new(p.start + 1 .. (p.stop + 1), nil)] } ; @parent += 1
          # <-- action
        end

      end
      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )

    end

    # lexer rule start_proc! (START_PROC)
    # (in argument.ruby.g)
    def start_proc!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      
      # - - - - main rule block - - - -
      # at line 70:5: '(' ( WS )?
      match( 0x28 )
      # at line 70:9: ( WS )?
      alt_10 = 2
      look_10_0 = @input.peek( 1 )

      if ( look_10_0.between?( 0x9, 0xa ) || look_10_0 == 0x20 )
        alt_10 = 1
      end
      case alt_10
      when 1
        # at line 70:9: WS
        ws!

      end

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )

    end

    # lexer rule cexpr! (CEXPR)
    # (in argument.ruby.g)
    def cexpr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      type = CEXPR
      channel = ANTLR3::DEFAULT_CHANNEL
      # - - - - label initialization - - - -
      tk = nil


      
      # - - - - main rule block - - - -
      # at line 74:5: tk= EXPR
      tk_start_276 = self.character_index
      expr!
      tk = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = tk_start_276
        t.stop    = self.character_index - 1
      end
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action
         @pmodules[@parent][:args] << ArgItem.new(tk.start .. tk.stop, tk.text) if @parent >= 0 
        # <-- action
      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )

    end

    # lexer rule param_delim! (PARAM_DELIM)
    # (in argument.ruby.g)
    def param_delim!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      
      # - - - - main rule block - - - -
      # at line 79:5: ',' ( WS )?
      match( 0x2c )
      # at line 79:9: ( WS )?
      alt_11 = 2
      look_11_0 = @input.peek( 1 )

      if ( look_11_0.between?( 0x9, 0xa ) || look_11_0 == 0x20 )
        alt_11 = 1
      end
      case alt_11
      when 1
        # at line 79:9: WS
        ws!

      end

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule expr! (EXPR)
    # (in argument.ruby.g)
    def expr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      
      # - - - - main rule block - - - -
      # at line 84:5: '(' ( EXPR | ~ ( ')' ) )* ')'
      match( 0x28 )
      # at line 84:9: ( EXPR | ~ ( ')' ) )*
      while true # decision 12
        alt_12 = 3
        look_12_0 = @input.peek( 1 )

        if ( look_12_0 == 0x28 )
          alt_12 = 1
        elsif ( look_12_0.between?( 0x0, 0x27 ) || look_12_0.between?( 0x2a, 0xffff ) )
          alt_12 = 2

        end
        case alt_12
        when 1
          # at line 84:11: EXPR
          expr!

        when 2
          # at line 84:18: ~ ( ')' )
          if @input.peek( 1 ).between?( 0x0, 0x28 ) || @input.peek( 1 ).between?( 0x2a, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 12
        end
      end # loop for decision 12
      match( 0x29 )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )

    end

    # lexer rule start_argument! (START_ARGUMENT)
    # (in argument.ruby.g)
    def start_argument!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      type = START_ARGUMENT
      channel = ANTLR3::DEFAULT_CHANNEL
      # - - - - label initialization - - - -
      p = nil


      
      # - - - - main rule block - - - -
      # at line 88:5: p= PARAM_DELIM
      p_start_344 = self.character_index
      param_delim!
      p = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = p_start_344
        t.stop    = self.character_index - 1
      end
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action
         @pmodules[@parent][:args] << ArgItem.new(p.start + 1 .. (p.stop + 1), nil) if @parent >= 0 
        # <-- action
      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # lexer rule end_func! (END_FUNC)
    # (in argument.ruby.g)
    def end_func!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )

      type = END_FUNC
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 93:5: ')'
      match( 0x29 )
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action
         @parent -= 1 if @parent > 0 
        # <-- action
      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 10 )

    end

    # lexer rule ws! (WS)
    # (in argument.ruby.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )

      type = WS
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 97:5: ( ' ' | '\\t' | '\\n' )+
      # at file 97:5: ( ' ' | '\\t' | '\\n' )+
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


      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 11 )

    end

    # lexer rule id! (ID)
    # (in argument.ruby.g)
    def id!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )

      
      # - - - - main rule block - - - -
      # at line 102:5: ( 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )* | DOUBLEQUOTED_STRING )
      alt_15 = 2
      look_15_0 = @input.peek( 1 )

      if ( look_15_0.between?( 0x41, 0x5a ) )
        alt_15 = 1
      elsif ( look_15_0 == 0x22 )
        alt_15 = 2
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 15, 0 )
      end
      case alt_15
      when 1
        # at line 102:7: 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        match_range( 0x41, 0x5a )
        # at line 102:18: ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        while true # decision 14
          alt_14 = 2
          look_14_0 = @input.peek( 1 )

          if ( look_14_0.between?( 0x23, 0x24 ) || look_14_0.between?( 0x30, 0x39 ) || look_14_0.between?( 0x41, 0x5a ) || look_14_0 == 0x5f )
            alt_14 = 1

          end
          case alt_14
          when 1
            # at line 
            if @input.peek( 1 ).between?( 0x23, 0x24 ) || @input.peek( 1 ).between?( 0x30, 0x39 ) || @input.peek( 1 ).between?( 0x41, 0x5a ) || @input.peek(1) == 0x5f
              @input.consume
            else
              @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

              mse = MismatchedSet( nil )
              recover mse
              raise mse
            end



          else
            break # out of loop for decision 14
          end
        end # loop for decision 14

      when 2
        # at line 103:7: DOUBLEQUOTED_STRING
        doublequoted_string!

      end
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 12 )

    end

    # lexer rule doublequoted_string! (DOUBLEQUOTED_STRING)
    # (in argument.ruby.g)
    def doublequoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )

      
      # - - - - main rule block - - - -
      # at line 108:5: '\"' (~ ( '\"' ) )* '\"'
      match( 0x22 )
      # at line 108:9: (~ ( '\"' ) )*
      while true # decision 16
        alt_16 = 2
        look_16_0 = @input.peek( 1 )

        if ( look_16_0.between?( 0x0, 0x21 ) || look_16_0.between?( 0x23, 0xffff ) )
          alt_16 = 1

        end
        case alt_16
        when 1
          # at line 108:11: ~ ( '\"' )
          if @input.peek( 1 ).between?( 0x0, 0x21 ) || @input.peek( 1 ).between?( 0x23, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 16
        end
      end # loop for decision 16
      match( 0x22 )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 13 )

    end

    # main rule used to study the input at the current position,
    # and choose the proper lexer rule to call in order to
    # fetch the next token
    # 
    # usually, you don't make direct calls to this method,
    # but instead use the next_token method, which will
    # build and emit the actual next token
    def token!
      # at line 1:39: ( QUOTED_STRING | SL_COMMENT | ML_COMMENT | PLSQL_MODULE | CEXPR | START_ARGUMENT | END_FUNC | WS )
      alt_17 = 8
      case look_17 = @input.peek( 1 )
      when 0x27, 0x6e then alt_17 = 1
      when 0x2d then alt_17 = 2
      when 0x2f then alt_17 = 3
      when 0x22, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a then alt_17 = 4
      when 0x28 then alt_17 = 5
      when 0x2c then alt_17 = 6
      when 0x29 then alt_17 = 7
      when 0x9, 0xa, 0x20 then alt_17 = 8
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 17, 0 )
      end
      case alt_17
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
        # at line 1:77: PLSQL_MODULE
        plsql_module!

      when 5
        # at line 1:90: CEXPR
        cexpr!

      when 6
        # at line 1:96: START_ARGUMENT
        start_argument!

      when 7
        # at line 1:111: END_FUNC
        end_func!

      when 8
        # at line 1:120: WS
        ws!

      end
    end

    
    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA9 < ANTLR3::DFA
      EOT = unpack( 15, -1 )
      EOF = unpack( 15, -1 )
      MIN = unpack( 1, 34, 1, 9, 1, 0, 1, 9, 1, 34, 1, -1, 1, 0, 2, 9, 1, 
                    0, 1, 9, 2, -1, 1, 0, 1, 9 )
      MAX = unpack( 1, 90, 1, 95, 1, -1, 1, 95, 1, 90, 1, -1, 1, -1, 1, 
                    46, 1, 95, 1, -1, 1, 95, 2, -1, 1, -1, 1, 46 )
      ACCEPT = unpack( 5, -1, 1, 3, 5, -1, 1, 1, 1, 2, 2, -1 )
      SPECIAL = unpack( 2, -1, 1, 1, 3, -1, 1, 2, 2, -1, 1, 0, 3, -1, 1, 
                        3, 1, -1 )
      TRANSITION = [
        unpack( 1, 2, 30, -1, 26, 1 ),
        unpack( 2, 5, 21, -1, 1, 5, 2, -1, 2, 3, 3, -1, 1, 5, 5, -1, 1, 
                 4, 1, -1, 10, 3, 7, -1, 26, 3, 4, -1, 1, 3 ),
        unpack( 34, 6, 1, 7, 65501, 6 ),
        unpack( 2, 5, 21, -1, 1, 5, 2, -1, 2, 3, 3, -1, 1, 5, 5, -1, 1, 
                 4, 1, -1, 10, 3, 7, -1, 26, 3, 4, -1, 1, 3 ),
        unpack( 1, 9, 30, -1, 26, 8 ),
        unpack(  ),
        unpack( 34, 6, 1, 7, 65501, 6 ),
        unpack( 2, 5, 21, -1, 1, 5, 7, -1, 1, 5, 5, -1, 1, 4 ),
        unpack( 2, 12, 21, -1, 1, 12, 2, -1, 2, 10, 3, -1, 1, 12, 5, -1, 
                 1, 11, 1, -1, 10, 10, 7, -1, 26, 10, 4, -1, 1, 10 ),
        unpack( 34, 13, 1, 14, 65501, 13 ),
        unpack( 2, 12, 21, -1, 1, 12, 2, -1, 2, 10, 3, -1, 1, 12, 5, -1, 
                 1, 11, 1, -1, 10, 10, 7, -1, 26, 10, 4, -1, 1, 10 ),
        unpack(  ),
        unpack(  ),
        unpack( 34, 13, 1, 14, 65501, 13 ),
        unpack( 2, 12, 21, -1, 1, 12, 7, -1, 1, 12, 5, -1, 1, 11 )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 9
      

      def description
        <<-'__dfa_description__'.strip!
          59:1: PLSQL_MODULE : ( (tk1= ID '.' tk2= ID '.' tk3= ID ( WS )? p= START_PROC ) | (tk1= ID '.' tk2= ID ( WS )? p= START_PROC ) | ( ID ( WS )? p= START_PROC ) );
        __dfa_description__
      end
    end

    
    private
    
    def initialize_dfas
      super rescue nil
      @dfa9 = DFA9.new( self, 9 ) do |s|
        case s
        when 0
          look_9_9 = @input.peek
          s = -1
          if ( look_9_9.between?( 0x0, 0x21 ) || look_9_9.between?( 0x23, 0xffff ) )
            s = 13
          elsif ( look_9_9 == 0x22 )
            s = 14
          end

        when 1
          look_9_2 = @input.peek
          s = -1
          if ( look_9_2.between?( 0x0, 0x21 ) || look_9_2.between?( 0x23, 0xffff ) )
            s = 6
          elsif ( look_9_2 == 0x22 )
            s = 7
          end

        when 2
          look_9_6 = @input.peek
          s = -1
          if ( look_9_6 == 0x22 )
            s = 7
          elsif ( look_9_6.between?( 0x0, 0x21 ) || look_9_6.between?( 0x23, 0xffff ) )
            s = 6
          end

        when 3
          look_9_13 = @input.peek
          s = -1
          if ( look_9_13 == 0x22 )
            s = 14
          elsif ( look_9_13.between?( 0x0, 0x21 ) || look_9_13.between?( 0x23, 0xffff ) )
            s = 13
          end

        end
        
        if s < 0
          @state.backtracking > 0 and raise ANTLR3::Error::BacktrackingFailed
          nva = ANTLR3::Error::NoViableAlternative.new( @dfa9.description, 9, s, input )
          @dfa9.error( nva )
          raise nva
        end
        
        s
      end

    end
  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end
# - - - - - - begin action @all::footer - - - - - -
# argument.ruby.g


	end

# - - - - - - end action @all::footer - - - - - - -


