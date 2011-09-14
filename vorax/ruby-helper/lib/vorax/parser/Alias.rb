#!/usr/bin/env ruby
#
# alias.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: alias.ruby.g
# Generated at: 2011-09-14 15:17:04
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


module Alias
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all 
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :JOIN_CLAUSE => 12, :DOUBLEQUOTED_STRING => 13, :RBR => 16, 
                   :TABLE_REFERENCE_WITH_ALIAS => 20, :UPDATE => 11, :ID => 14, 
                   :EOF => -1, :LBR => 15, :TABLE_REFERENCE => 8, :ML_COMMENT => 6, 
                   :WS => 7, :PLAIN_TABLE_REF => 19, :SL_COMMENT => 5, :SUB_SELECT => 17, 
                   :OBJ_ALIAS => 18, :QUOTED_STRING => 4, :FROM => 9, :INTO => 10 )
    
  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = Alias
    include TokenData
    include ANTLR3::FilterMode

    
    begin
      generated_using( "alias.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "QUOTED_STRING", "SL_COMMENT", "ML_COMMENT", "FROM", 
                     "INTO", "UPDATE", "JOIN_CLAUSE", "WS", "ID", "DOUBLEQUOTED_STRING", 
                     "LBR", "RBR", "SUB_SELECT", "OBJ_ALIAS", "PLAIN_TABLE_REF", 
                     "TABLE_REFERENCE_WITH_ALIAS", "TABLE_REFERENCE", "Tokens", 
                     "synpred29_Alias", "synpred30_Alias", "synpred31_Alias" ].freeze
    RULE_METHODS = [ :quoted_string!, :sl_comment!, :ml_comment!, :from!, 
                     :into!, :update!, :join_clause!, :ws!, :id!, :doublequoted_string!, 
                     :lbr!, :rbr!, :sub_select!, :obj_alias!, :plain_table_ref!, 
                     :table_reference_with_alias!, :table_reference!, :token!, 
                     :synpred_29_alias!, :synpred_30_alias!, :synpred_31_alias! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )
      # - - - - - - begin action @lexer::init - - - - - -
      # alias.ruby.g


        @aliases = []
        @last_table = nil;
        @last_owner = nil;
        @last_dblink = nil;
        @last_alias = nil;

      # - - - - - - end action @lexer::init - - - - - - -

    end
    
    # - - - - - - begin action @lexer::members - - - - - -
    # alias.ruby.g



      @@level = 0
     
      attr_accessor :aliases, :cpos

      def self.columns_for(stmt, prefix)
        cols = []
        text = stmt.upcase
        prefix.upcase!
        sources = self.gather_for(text, 0)
        # is the prefix a simple word?
        if prefix =~ /^[A-Z0-9$#_]+$/
          # it could be an alias... is it?
          a = sources.find do |src| 
            src.idn && src.idn == prefix 
          end
          if a && a.expr
            #get subselect columns
            collect_columns(a.object, sources, 1, cols)
          elsif a
            cols << "#{a.owner=="" ? "" : a.owner + "."}#{a.object}.*"
          else
            cols << "#{prefix}.*"
          end
        end
        cols
      end

      def self.all_columns_for(stmt)
        cols = []
        text = stmt.upcase
        sources = self.gather_for(text, 0)
        sources.each do |source|
          if source.expr
         	  collect_columns(source.object, sources, 1, cols)
          else
            cols << "#{source.owner=="" ? "" : source.owner + "."}#{source.object}.*"
         	end
        end
        cols
      end

      private

      def self.gather_for(text, position=nil)
        input = ANTLR3::StringStream.new(text.upcase)
        lexer = Alias::Lexer.new(input)
        lexer.cpos = position
        lexer.map
        lexer.aliases
      end

      def self.collect_columns(stmt, sources, level, columns)
        text = stmt.upcase
        lexer = Plsql::Lexer.new(text)
        tokens = ANTLR3::CommonTokenStream.new(lexer)
        parser = Plsql::Parser.new(tokens, :error_output => StringIO.new)
        begin
          result = parser.select_command
        rescue
          # ignore errors
        end
        parser.columns.each do |col|
          if col =~ /^[A-Z0-9$#_]+$/
            columns << col
          elsif col =~ /^[A-Z0-9]+\.\*$/
            # find aliases
            a = sources.find { |als| als.idn == col.split('.')[0] && als.level == level }
            if a.expr
              collect_columns(a.object, sources, level+1, columns)
            else
              columns << "#{a.object}.*"
            end
          elsif col == '*'
            lvlsrc = sources.find_all { |e| e.level == level }
            lvlsrc.each do |src|
              if src.expr
                collect_columns(src.object, sources, level+1, columns)
              else
                columns << "#{src.owner=="" ? "" : src.owner + "."}#{src.object}.*"
              end
            end
          end
        end
      end

      AliasItem = Struct.new(:idn, :object, :owner, :dblink, :expr, :level)

      KEYS = [ 'ON', 'WHERE', 'FROM', 'CONNECT', 'START', 'GROUP', 'HAVING', 'MODEL' ]

      def add_alias(idn, object, owner=nil, dblink=nil, expr=false)
        @expr = false unless expr
        @aliases << AliasItem.new(idn, object, owner, dblink, expr, @@level)
        @last_table = nil;
        @last_owner = nil;
        @last_dblink = nil;
        @last_alias = nil;
      end

      def next_word
        i = self.input.index - 1
        result = ''
        while prev_char = self.input.data[i..i]
          i -= 1
          break if prev_char !~ /[A-Z0-9$#_]/
          result += prev_char + result
        end
        i = 1
        while next_char = self.input.look(i)
          i += 1
          break if next_char !~ /[A-Z0-9$#_]/
          result += next_char
        end
        result
      end


    # - - - - - - end action @lexer::members - - - - - - -

    
    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule quoted_string! (QUOTED_STRING)
    # (in alias.ruby.g)
    def quoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = QUOTED_STRING
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 138:5: ( 'n' )? '\\'' ( '\\'\\'' | ~ ( '\\'' ) )* '\\''
      # at line 138:5: ( 'n' )?
      alt_1 = 2
      look_1_0 = @input.peek( 1 )

      if ( look_1_0 == 0x6e )
        alt_1 = 1
      end
      case alt_1
      when 1
        # at line 138:7: 'n'
        match( 0x6e )

      end
      match( 0x27 )
      # at line 138:19: ( '\\'\\'' | ~ ( '\\'' ) )*
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
          # at line 138:21: '\\'\\''
          match( "''" )

        when 2
          # at line 138:30: ~ ( '\\'' )
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
    # (in alias.ruby.g)
    def sl_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = SL_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 142:5: '--' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
      match( "--" )
      # at line 142:10: (~ ( '\\n' | '\\r' ) )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( 0x0, 0x9 ) || look_3_0.between?( 0xb, 0xc ) || look_3_0.between?( 0xe, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 0:0: ~ ( '\\n' | '\\r' )
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
      # at line 142:24: ( '\\r' )?
      alt_4 = 2
      look_4_0 = @input.peek( 1 )

      if ( look_4_0 == 0xd )
        alt_4 = 1
      end
      case alt_4
      when 1
        # at line 0:0: '\\r'
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
    # (in alias.ruby.g)
    def ml_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = ML_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 146:5: '/*' ( options {greedy=false; } : . )* '*/'
      match( "/*" )
      # at line 146:10: ( options {greedy=false; } : . )*
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
          # at line 146:38: .
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

    # lexer rule from! (FROM)
    # (in alias.ruby.g)
    def from!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = FROM
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 150:5: 'FROM' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "FROM" )
      ws!
      table_reference!
      # at line 150:31: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 8
        alt_8 = 2
        look_8_0 = @input.peek( 1 )

        if ( look_8_0.between?( 0x9, 0xa ) || look_8_0 == 0x20 || look_8_0 == 0x2c )
          alt_8 = 1

        end
        case alt_8
        when 1
          # at line 150:32: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 150:32: ( WS )?
          alt_6 = 2
          look_6_0 = @input.peek( 1 )

          if ( look_6_0.between?( 0x9, 0xa ) || look_6_0 == 0x20 )
            alt_6 = 1
          end
          case alt_6
          when 1
            # at line 0:0: WS
            ws!

          end
          match( 0x2c )
          # at line 150:40: ( WS )?
          alt_7 = 2
          look_7_0 = @input.peek( 1 )

          if ( look_7_0.between?( 0x9, 0xa ) || look_7_0 == 0x20 )
            alt_7 = 1
          end
          case alt_7
          when 1
            # at line 0:0: WS
            ws!

          end
          table_reference!

        else
          break # out of loop for decision 8
        end
      end # loop for decision 8

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )

    end

    # lexer rule into! (INTO)
    # (in alias.ruby.g)
    def into!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      type = INTO
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 154:5: 'INTO' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "INTO" )
      ws!
      table_reference!
      # at line 154:31: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 11
        alt_11 = 2
        look_11_0 = @input.peek( 1 )

        if ( look_11_0.between?( 0x9, 0xa ) || look_11_0 == 0x20 || look_11_0 == 0x2c )
          alt_11 = 1

        end
        case alt_11
        when 1
          # at line 154:32: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 154:32: ( WS )?
          alt_9 = 2
          look_9_0 = @input.peek( 1 )

          if ( look_9_0.between?( 0x9, 0xa ) || look_9_0 == 0x20 )
            alt_9 = 1
          end
          case alt_9
          when 1
            # at line 0:0: WS
            ws!

          end
          match( 0x2c )
          # at line 154:40: ( WS )?
          alt_10 = 2
          look_10_0 = @input.peek( 1 )

          if ( look_10_0.between?( 0x9, 0xa ) || look_10_0 == 0x20 )
            alt_10 = 1
          end
          case alt_10
          when 1
            # at line 0:0: WS
            ws!

          end
          table_reference!

        else
          break # out of loop for decision 11
        end
      end # loop for decision 11

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )

    end

    # lexer rule update! (UPDATE)
    # (in alias.ruby.g)
    def update!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      type = UPDATE
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 158:5: 'UPDATE' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "UPDATE" )
      ws!
      table_reference!
      # at line 158:33: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 14
        alt_14 = 2
        look_14_0 = @input.peek( 1 )

        if ( look_14_0.between?( 0x9, 0xa ) || look_14_0 == 0x20 || look_14_0 == 0x2c )
          alt_14 = 1

        end
        case alt_14
        when 1
          # at line 158:34: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 158:34: ( WS )?
          alt_12 = 2
          look_12_0 = @input.peek( 1 )

          if ( look_12_0.between?( 0x9, 0xa ) || look_12_0 == 0x20 )
            alt_12 = 1
          end
          case alt_12
          when 1
            # at line 0:0: WS
            ws!

          end
          match( 0x2c )
          # at line 158:42: ( WS )?
          alt_13 = 2
          look_13_0 = @input.peek( 1 )

          if ( look_13_0.between?( 0x9, 0xa ) || look_13_0 == 0x20 )
            alt_13 = 1
          end
          case alt_13
          when 1
            # at line 0:0: WS
            ws!

          end
          table_reference!

        else
          break # out of loop for decision 14
        end
      end # loop for decision 14

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )

    end

    # lexer rule join_clause! (JOIN_CLAUSE)
    # (in alias.ruby.g)
    def join_clause!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      type = JOIN_CLAUSE
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 162:5: 'JOIN' WS TABLE_REFERENCE ( WS )?
      match( "JOIN" )
      ws!
      table_reference!
      # at line 162:31: ( WS )?
      alt_15 = 2
      look_15_0 = @input.peek( 1 )

      if ( look_15_0.between?( 0x9, 0xa ) || look_15_0 == 0x20 )
        alt_15 = 1
      end
      case alt_15
      when 1
        # at line 0:0: WS
        ws!

      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule ws! (WS)
    # (in alias.ruby.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      type = WS
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 166:5: ( ' ' | '\\t' | '\\n' )+
      # at file 166:5: ( ' ' | '\\t' | '\\n' )+
      match_count_16 = 0
      while true
        alt_16 = 2
        look_16_0 = @input.peek( 1 )

        if ( look_16_0.between?( 0x9, 0xa ) || look_16_0 == 0x20 )
          alt_16 = 1

        end
        case alt_16
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
          match_count_16 > 0 and break
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          eee = EarlyExit(16)


          raise eee
        end
        match_count_16 += 1
      end


      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )

    end

    # lexer rule id! (ID)
    # (in alias.ruby.g)
    def id!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      
      # - - - - main rule block - - - -
      # at line 171:5: ( 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )* | DOUBLEQUOTED_STRING )
      alt_18 = 2
      look_18_0 = @input.peek( 1 )

      if ( look_18_0.between?( 0x41, 0x5a ) )
        alt_18 = 1
      elsif ( look_18_0 == 0x22 )
        alt_18 = 2
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 18, 0 )
      end
      case alt_18
      when 1
        # at line 171:7: 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        match_range( 0x41, 0x5a )
        # at line 171:18: ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        while true # decision 17
          alt_17 = 2
          look_17_0 = @input.peek( 1 )

          if ( look_17_0.between?( 0x23, 0x24 ) || look_17_0.between?( 0x30, 0x39 ) || look_17_0.between?( 0x41, 0x5a ) || look_17_0 == 0x5f )
            alt_17 = 1

          end
          case alt_17
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
            break # out of loop for decision 17
          end
        end # loop for decision 17

      when 2
        # at line 172:7: DOUBLEQUOTED_STRING
        doublequoted_string!

      end
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # lexer rule doublequoted_string! (DOUBLEQUOTED_STRING)
    # (in alias.ruby.g)
    def doublequoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )

      
      # - - - - main rule block - - - -
      # at line 177:5: '\"' (~ ( '\"' ) )* '\"'
      match( 0x22 )
      # at line 177:9: (~ ( '\"' ) )*
      while true # decision 19
        alt_19 = 2
        look_19_0 = @input.peek( 1 )

        if ( look_19_0.between?( 0x0, 0x21 ) || look_19_0.between?( 0x23, 0xffff ) )
          alt_19 = 1

        end
        case alt_19
        when 1
          # at line 177:11: ~ ( '\"' )
          if @input.peek( 1 ).between?( 0x0, 0x21 ) || @input.peek( 1 ).between?( 0x23, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 19
        end
      end # loop for decision 19
      match( 0x22 )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 10 )

    end

    # lexer rule lbr! (LBR)
    # (in alias.ruby.g)
    def lbr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )

      type = LBR
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 181:5: '('
      match( 0x28 )
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action
         @@level += 1 
        # <-- action
      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 11 )

    end

    # lexer rule rbr! (RBR)
    # (in alias.ruby.g)
    def rbr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )

      type = RBR
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 185:5: ')'
      match( 0x29 )
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action
         @@level -= 1 
        # <-- action
      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 12 )

    end

    # lexer rule sub_select! (SUB_SELECT)
    # (in alias.ruby.g)
    def sub_select!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )

      
      # - - - - main rule block - - - -
      # at line 190:5: '(' ( SUB_SELECT | ~ ( ')' ) )* ')'
      match( 0x28 )
      # at line 190:9: ( SUB_SELECT | ~ ( ')' ) )*
      while true # decision 20
        alt_20 = 3
        look_20_0 = @input.peek( 1 )

        if ( look_20_0 == 0x28 )
          look_20_2 = @input.peek( 2 )

          if ( syntactic_predicate?( :synpred29_Alias ) )
            alt_20 = 1
          elsif ( syntactic_predicate?( :synpred30_Alias ) )
            alt_20 = 2

          end
        elsif ( look_20_0.between?( 0x0, 0x27 ) || look_20_0.between?( 0x2a, 0xffff ) )
          alt_20 = 2

        end
        case alt_20
        when 1
          # at line 190:11: SUB_SELECT
          sub_select!

        when 2
          # at line 190:24: ~ ( ')' )
          if @input.peek( 1 ).between?( 0x0, 0x28 ) || @input.peek( 1 ).between?( 0x2a, 0xff )
            @input.consume
          else
            @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 20
        end
      end # loop for decision 20
      match( 0x29 )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 13 )

    end

    # lexer rule obj_alias! (OBJ_ALIAS)
    # (in alias.ruby.g)
    def obj_alias!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )
      # - - - - label initialization - - - -
      __ID1__ = nil


      
      # - - - - main rule block - - - -
      # at line 195:5: {...}? ID
      unless ( ( (KEYS.find { |key| next_word() == key }).nil?  ) )
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise FailedPredicate( "OBJ_ALIAS", "(KEYS.find { |key| next_word() == key }).nil? " )
      end
      __ID1___start_446 = self.character_index
      id!
      __ID1__ = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = __ID1___start_446
        t.stop    = self.character_index - 1
      end
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action

            @last_alias = __ID1__.text
          
        # <-- action
      end

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 14 )

    end

    # lexer rule plain_table_ref! (PLAIN_TABLE_REF)
    # (in alias.ruby.g)
    def plain_table_ref!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )
      # - - - - label initialization - - - -
      owner = nil
      table = nil
      dblink = nil


      
      # - - - - main rule block - - - -
      # at line 203:5: (owner= ID '.' )? table= ID ( '@' dblink= ID )?
      # at line 203:5: (owner= ID '.' )?
      alt_21 = 2
      alt_21 = @dfa21.predict( @input )
      case alt_21
      when 1
        # at line 203:6: owner= ID '.'
        owner_start_470 = self.character_index
        id!
        owner = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = owner_start_470
          t.stop    = self.character_index - 1
        end
        match( 0x2e )

      end
      table_start_478 = self.character_index
      id!
      table = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = table_start_478
        t.stop    = self.character_index - 1
      end
      # at line 203:30: ( '@' dblink= ID )?
      alt_22 = 2
      look_22_0 = @input.peek( 1 )

      if ( look_22_0 == 0x40 )
        alt_22 = 1
      end
      case alt_22
      when 1
        # at line 203:31: '@' dblink= ID
        match( 0x40 )
        dblink_start_485 = self.character_index
        id!
        dblink = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = dblink_start_485
          t.stop    = self.character_index - 1
        end

      end
      # syntactic predicate action gate test
      if @state.backtracking == 1
        # --> action

            @last_table = table ? table.text : ''
            @last_owner = owner ? owner.text : ''
            @last_dblink = dblink ? dblink.text : ''
          
        # <-- action
      end

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 15 )

    end

    # lexer rule table_reference_with_alias! (TABLE_REFERENCE_WITH_ALIAS)
    # (in alias.ruby.g)
    def table_reference_with_alias!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )

      
      # - - - - main rule block - - - -
      # at line 212:5: PLAIN_TABLE_REF WS OBJ_ALIAS
      plain_table_ref!
      ws!
      obj_alias!

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 16 )

    end

    # lexer rule table_reference! (TABLE_REFERENCE)
    # (in alias.ruby.g)
    def table_reference!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 17 )
      # - - - - label initialization - - - -
      ss = nil


      
      # - - - - main rule block - - - -
      # at line 217:3: ( (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? ) | ( TABLE_REFERENCE_WITH_ALIAS ( WS )? ) | ( PLAIN_TABLE_REF ( WS )? ) )
      alt_27 = 3
      case look_27 = @input.peek( 1 )
      when 0x28 then alt_27 = 1
      when 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a then look_27_2 = @input.peek( 2 )

      if ( syntactic_predicate?( :synpred37_Alias ) )
        alt_27 = 2
      elsif ( true )
        alt_27 = 3
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 27, 2 )
      end
      when 0x22 then look_27_3 = @input.peek( 2 )

      if ( syntactic_predicate?( :synpred37_Alias ) )
        alt_27 = 2
      elsif ( true )
        alt_27 = 3
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 27, 3 )
      end
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise NoViableAlternative( "", 27, 0 )
      end
      case alt_27
      when 1
        # at line 217:5: (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? )
        # at line 217:5: (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? )
        # at line 217:6: ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )?
        ss_start_526 = self.character_index
        sub_select!
        ss = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = ss_start_526
          t.stop    = self.character_index - 1
        end
        # at line 217:20: ( WS )?
        alt_23 = 2
        look_23_0 = @input.peek( 1 )

        if ( look_23_0.between?( 0x9, 0xa ) || look_23_0 == 0x20 )
          alt_23 = 1
        end
        case alt_23
        when 1
          # at line 0:0: WS
          ws!

        end
        # at line 217:24: ( OBJ_ALIAS )?
        alt_24 = 2
        look_24_0 = @input.peek( 1 )

        if ( look_24_0 == 0x22 || look_24_0.between?( 0x41, 0x5a ) )
          alt_24 = 1
        end
        case alt_24
        when 1
          # at line 0:0: OBJ_ALIAS
          obj_alias!

        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action

                if @last_alias
                  add_alias(@last_alias, ss.text, nil, nil, true)
                else
                  add_alias(nil, ss.text, nil, nil, true)
                end
                text = ss.text
                @aliases += Alias::Lexer.gather_for(text,0)
                @input.consume
              
          # <-- action
        end

      when 2
        # at line 229:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
        # at line 229:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
        # at line 229:6: TABLE_REFERENCE_WITH_ALIAS ( WS )?
        table_reference_with_alias!
        # at line 229:33: ( WS )?
        alt_25 = 2
        look_25_0 = @input.peek( 1 )

        if ( look_25_0.between?( 0x9, 0xa ) || look_25_0 == 0x20 )
          alt_25 = 1
        end
        case alt_25
        when 1
          # at line 0:0: WS
          ws!

        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action

                add_alias(@last_alias, @last_table, @last_owner, @last_dblink)
              
          # <-- action
        end

      when 3
        # at line 234:5: ( PLAIN_TABLE_REF ( WS )? )
        # at line 234:5: ( PLAIN_TABLE_REF ( WS )? )
        # at line 234:6: PLAIN_TABLE_REF ( WS )?
        plain_table_ref!
        # at line 234:22: ( WS )?
        alt_26 = 2
        look_26_0 = @input.peek( 1 )

        if ( look_26_0.between?( 0x9, 0xa ) || look_26_0 == 0x20 )
          alt_26 = 1
        end
        case alt_26
        when 1
          # at line 0:0: WS
          ws!

        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action

                add_alias(nil, @last_table, @last_owner, @last_dblink)
              
          # <-- action
        end

      end
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
      # at line 1:39: ( QUOTED_STRING | SL_COMMENT | ML_COMMENT | FROM | INTO | UPDATE | JOIN_CLAUSE | WS | LBR | RBR )
      alt_28 = 10
      alt_28 = @dfa28.predict( @input )
      case alt_28
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
        # at line 1:77: FROM
        from!

      when 5
        # at line 1:82: INTO
        into!

      when 6
        # at line 1:87: UPDATE
        update!

      when 7
        # at line 1:94: JOIN_CLAUSE
        join_clause!

      when 8
        # at line 1:106: WS
        ws!

      when 9
        # at line 1:109: LBR
        lbr!

      when 10
        # at line 1:113: RBR
        rbr!

      end
    end
    # 
    # syntactic predicate synpred29_Alias
    # 
    # (in alias.ruby.g)
    # 
    # 
    # This is an imaginary rule inserted by ANTLR to
    # implement a syntactic predicate decision
    # 
    def synpred29_Alias
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 47 )

      # at line 190:11: SUB_SELECT
      sub_select!

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 47 )

    end
    # 
    # syntactic predicate synpred30_Alias
    # 
    # (in alias.ruby.g)
    # 
    # 
    # This is an imaginary rule inserted by ANTLR to
    # implement a syntactic predicate decision
    # 
    def synpred30_Alias
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 48 )

      # at line 190:24: ~ ( ')' )
      if @input.peek( 1 ).between?( 0x0, 0x28 ) || @input.peek( 1 ).between?( 0x2a, 0xff )
        @input.consume
      else
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        mse = MismatchedSet( nil )
        recover mse
        raise mse
      end



    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 48 )

    end
    # 
    # syntactic predicate synpred31_Alias
    # 
    # (in alias.ruby.g)
    # 
    # 
    # This is an imaginary rule inserted by ANTLR to
    # implement a syntactic predicate decision
    # 
    def synpred31_Alias
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 49 )
      owner = nil

      # at line 203:6: owner= ID '.'
      owner_start_470 = self.character_index
      id!
      owner = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = owner_start_470
        t.stop    = self.character_index - 1
      end
      match( 0x2e )

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 49 )

    end
    # 
    # syntactic predicate synpred37_Alias
    # 
    # (in alias.ruby.g)
    # 
    # 
    # This is an imaginary rule inserted by ANTLR to
    # implement a syntactic predicate decision
    # 
    def synpred37_Alias
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 55 )

      # at line 229:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
      # at line 229:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
      # at line 229:6: TABLE_REFERENCE_WITH_ALIAS ( WS )?
      table_reference_with_alias!
      # at line 229:33: ( WS )?
      alt_38 = 2
      look_38_0 = @input.peek( 1 )

      if ( look_38_0.between?( 0x9, 0xa ) || look_38_0 == 0x20 )
        alt_38 = 1
      end
      case alt_38
      when 1
        # at line 0:0: WS
        ws!

      end


    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 55 )

    end

    
    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA21 < ANTLR3::DFA
      EOT = unpack( 1, -1, 1, 4, 1, -1, 1, 4, 4, -1, 1, 4, 2, -1, 1, 4, 
                    1, -1, 1, 4, 6, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 3, -1, 1, 4, 4, -1, 1, 4, 3, -1, 1, 4, 
                    4, -1, 1, 4, 10, -1 )
      EOF = unpack( 891, -1 )
      MIN = unpack( 1, 34, 1, 35, 1, 0, 1, 35, 3, -1, 1, 0, 1, 46, 2, -1, 
                    1, 35, 1, -1, 1, 46, 1, 0, 5, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 
                    1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 
                    4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 
                    2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 
                    1, 46, 1, 0, 2, -1, 1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 
                    1, 35, 4, -1, 1, 46, 1, 0, 2, -1, 1, 0, 4, -1, 2, 0 )
      MAX = unpack( 1, 90, 1, 95, 1, -1, 1, 95, 3, -1, 1, -1, 1, 46, 2, 
                    -1, 1, 95, 1, -1, 1, 46, 1, -1, 5, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 
                    1, 46, 1, -1, 2, -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, 
                    -1, 1, 95, 4, -1, 1, 46, 1, -1, 2, -1, 1, 0, 4, -1, 
                    2, 0 )
      ACCEPT = unpack( 4, -1, 1, 2, 1, 1, 885, -1 )
      SPECIAL = unpack( 2, -1, 1, 0, 4, -1, 1, 1, 6, -1, 1, 2, 11, -1, 1, 
                        3, 8, -1, 1, 4, 8, -1, 1, 5, 8, -1, 1, 6, 8, -1, 
                        1, 7, 8, -1, 1, 8, 8, -1, 1, 9, 8, -1, 1, 10, 8, 
                        -1, 1, 11, 8, -1, 1, 12, 8, -1, 1, 13, 8, -1, 1, 
                        14, 8, -1, 1, 15, 8, -1, 1, 16, 8, -1, 1, 17, 8, 
                        -1, 1, 18, 8, -1, 1, 19, 8, -1, 1, 20, 8, -1, 1, 
                        21, 8, -1, 1, 22, 8, -1, 1, 23, 8, -1, 1, 24, 8, 
                        -1, 1, 25, 8, -1, 1, 26, 8, -1, 1, 27, 8, -1, 1, 
                        28, 8, -1, 1, 29, 8, -1, 1, 30, 8, -1, 1, 31, 8, 
                        -1, 1, 32, 8, -1, 1, 33, 8, -1, 1, 34, 8, -1, 1, 
                        35, 8, -1, 1, 36, 8, -1, 1, 37, 8, -1, 1, 38, 8, 
                        -1, 1, 39, 8, -1, 1, 40, 8, -1, 1, 41, 8, -1, 1, 
                        42, 8, -1, 1, 43, 8, -1, 1, 44, 8, -1, 1, 45, 8, 
                        -1, 1, 46, 8, -1, 1, 47, 8, -1, 1, 48, 8, -1, 1, 
                        49, 8, -1, 1, 50, 8, -1, 1, 51, 8, -1, 1, 52, 8, 
                        -1, 1, 53, 8, -1, 1, 54, 8, -1, 1, 55, 8, -1, 1, 
                        56, 8, -1, 1, 57, 8, -1, 1, 58, 8, -1, 1, 59, 8, 
                        -1, 1, 60, 8, -1, 1, 61, 8, -1, 1, 62, 8, -1, 1, 
                        63, 8, -1, 1, 64, 8, -1, 1, 65, 8, -1, 1, 66, 8, 
                        -1, 1, 67, 8, -1, 1, 68, 8, -1, 1, 69, 8, -1, 1, 
                        70, 8, -1, 1, 71, 8, -1, 1, 72, 8, -1, 1, 73, 8, 
                        -1, 1, 74, 8, -1, 1, 75, 8, -1, 1, 76, 8, -1, 1, 
                        77, 8, -1, 1, 78, 8, -1, 1, 79, 8, -1, 1, 80, 8, 
                        -1, 1, 81, 8, -1, 1, 82, 8, -1, 1, 83, 8, -1, 1, 
                        84, 8, -1, 1, 85, 8, -1, 1, 86, 8, -1, 1, 87, 8, 
                        -1, 1, 88, 8, -1, 1, 89, 8, -1, 1, 90, 8, -1, 1, 
                        91, 8, -1, 1, 92, 8, -1, 1, 93, 8, -1, 1, 94, 8, 
                        -1, 1, 95, 8, -1, 1, 96, 8, -1, 1, 97, 8, -1, 1, 
                        98, 2, -1, 1, 99, 4, -1, 1, 100, 1, 101 )
      TRANSITION = [
        unpack( 1, 2, 30, -1, 26, 1 ),
        unpack( 2, 3, 9, -1, 1, 5, 1, -1, 10, 3, 7, -1, 26, 3, 4, -1, 1, 
                 3 ),
        unpack( 34, 7, 1, 8, 65501, 7 ),
        unpack( 2, 11, 9, -1, 1, 5, 1, -1, 10, 11, 7, -1, 26, 11, 4, -1, 
                 1, 11 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 34, 14, 1, 13, 65501, 14 ),
        unpack( 1, 5 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 20, 9, -1, 1, 5, 1, -1, 10, 20, 7, -1, 26, 20, 4, -1, 
                 1, 20 ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 26, 1, 25, 65501, 26 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 29, 9, -1, 1, 5, 1, -1, 10, 29, 7, -1, 26, 29, 4, -1, 
                 1, 29 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 35, 1, 34, 65501, 35 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 38, 9, -1, 1, 5, 1, -1, 10, 38, 7, -1, 26, 38, 4, -1, 
                 1, 38 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 44, 1, 43, 65501, 44 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 47, 9, -1, 1, 5, 1, -1, 10, 47, 7, -1, 26, 47, 4, -1, 
                 1, 47 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 53, 1, 52, 65501, 53 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 56, 9, -1, 1, 5, 1, -1, 10, 56, 7, -1, 26, 56, 4, -1, 
                 1, 56 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 62, 1, 61, 65501, 62 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 65, 9, -1, 1, 5, 1, -1, 10, 65, 7, -1, 26, 65, 4, -1, 
                 1, 65 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 71, 1, 70, 65501, 71 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 74, 9, -1, 1, 5, 1, -1, 10, 74, 7, -1, 26, 74, 4, -1, 
                 1, 74 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 80, 1, 79, 65501, 80 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 83, 9, -1, 1, 5, 1, -1, 10, 83, 7, -1, 26, 83, 4, -1, 
                 1, 83 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 89, 1, 88, 65501, 89 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 92, 9, -1, 1, 5, 1, -1, 10, 92, 7, -1, 26, 92, 4, -1, 
                 1, 92 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 98, 1, 97, 65501, 98 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 101, 9, -1, 1, 5, 1, -1, 10, 101, 7, -1, 26, 101, 4, 
                 -1, 1, 101 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 107, 1, 106, 65501, 107 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 110, 9, -1, 1, 5, 1, -1, 10, 110, 7, -1, 26, 110, 4, 
                 -1, 1, 110 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 116, 1, 115, 65501, 116 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 119, 9, -1, 1, 5, 1, -1, 10, 119, 7, -1, 26, 119, 4, 
                 -1, 1, 119 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 125, 1, 124, 65501, 125 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 128, 9, -1, 1, 5, 1, -1, 10, 128, 7, -1, 26, 128, 4, 
                 -1, 1, 128 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 134, 1, 133, 65501, 134 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 137, 9, -1, 1, 5, 1, -1, 10, 137, 7, -1, 26, 137, 4, 
                 -1, 1, 137 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 143, 1, 142, 65501, 143 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 146, 9, -1, 1, 5, 1, -1, 10, 146, 7, -1, 26, 146, 4, 
                 -1, 1, 146 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 152, 1, 151, 65501, 152 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 155, 9, -1, 1, 5, 1, -1, 10, 155, 7, -1, 26, 155, 4, 
                 -1, 1, 155 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 161, 1, 160, 65501, 161 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 164, 9, -1, 1, 5, 1, -1, 10, 164, 7, -1, 26, 164, 4, 
                 -1, 1, 164 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 170, 1, 169, 65501, 170 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 173, 9, -1, 1, 5, 1, -1, 10, 173, 7, -1, 26, 173, 4, 
                 -1, 1, 173 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 179, 1, 178, 65501, 179 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 182, 9, -1, 1, 5, 1, -1, 10, 182, 7, -1, 26, 182, 4, 
                 -1, 1, 182 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 188, 1, 187, 65501, 188 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 191, 9, -1, 1, 5, 1, -1, 10, 191, 7, -1, 26, 191, 4, 
                 -1, 1, 191 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 197, 1, 196, 65501, 197 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 200, 9, -1, 1, 5, 1, -1, 10, 200, 7, -1, 26, 200, 4, 
                 -1, 1, 200 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 206, 1, 205, 65501, 206 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 209, 9, -1, 1, 5, 1, -1, 10, 209, 7, -1, 26, 209, 4, 
                 -1, 1, 209 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 215, 1, 214, 65501, 215 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 218, 9, -1, 1, 5, 1, -1, 10, 218, 7, -1, 26, 218, 4, 
                 -1, 1, 218 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 224, 1, 223, 65501, 224 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 227, 9, -1, 1, 5, 1, -1, 10, 227, 7, -1, 26, 227, 4, 
                 -1, 1, 227 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 233, 1, 232, 65501, 233 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 236, 9, -1, 1, 5, 1, -1, 10, 236, 7, -1, 26, 236, 4, 
                 -1, 1, 236 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 242, 1, 241, 65501, 242 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 245, 9, -1, 1, 5, 1, -1, 10, 245, 7, -1, 26, 245, 4, 
                 -1, 1, 245 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 251, 1, 250, 65501, 251 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 254, 9, -1, 1, 5, 1, -1, 10, 254, 7, -1, 26, 254, 4, 
                 -1, 1, 254 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 260, 1, 259, 65501, 260 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 263, 9, -1, 1, 5, 1, -1, 10, 263, 7, -1, 26, 263, 4, 
                 -1, 1, 263 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 269, 1, 268, 65501, 269 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 272, 9, -1, 1, 5, 1, -1, 10, 272, 7, -1, 26, 272, 4, 
                 -1, 1, 272 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 278, 1, 277, 65501, 278 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 281, 9, -1, 1, 5, 1, -1, 10, 281, 7, -1, 26, 281, 4, 
                 -1, 1, 281 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 287, 1, 286, 65501, 287 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 290, 9, -1, 1, 5, 1, -1, 10, 290, 7, -1, 26, 290, 4, 
                 -1, 1, 290 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 296, 1, 295, 65501, 296 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 299, 9, -1, 1, 5, 1, -1, 10, 299, 7, -1, 26, 299, 4, 
                 -1, 1, 299 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 305, 1, 304, 65501, 305 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 308, 9, -1, 1, 5, 1, -1, 10, 308, 7, -1, 26, 308, 4, 
                 -1, 1, 308 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 314, 1, 313, 65501, 314 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 317, 9, -1, 1, 5, 1, -1, 10, 317, 7, -1, 26, 317, 4, 
                 -1, 1, 317 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 323, 1, 322, 65501, 323 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 326, 9, -1, 1, 5, 1, -1, 10, 326, 7, -1, 26, 326, 4, 
                 -1, 1, 326 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 332, 1, 331, 65501, 332 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 335, 9, -1, 1, 5, 1, -1, 10, 335, 7, -1, 26, 335, 4, 
                 -1, 1, 335 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 341, 1, 340, 65501, 341 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 344, 9, -1, 1, 5, 1, -1, 10, 344, 7, -1, 26, 344, 4, 
                 -1, 1, 344 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 350, 1, 349, 65501, 350 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 353, 9, -1, 1, 5, 1, -1, 10, 353, 7, -1, 26, 353, 4, 
                 -1, 1, 353 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 359, 1, 358, 65501, 359 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 362, 9, -1, 1, 5, 1, -1, 10, 362, 7, -1, 26, 362, 4, 
                 -1, 1, 362 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 368, 1, 367, 65501, 368 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 371, 9, -1, 1, 5, 1, -1, 10, 371, 7, -1, 26, 371, 4, 
                 -1, 1, 371 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 377, 1, 376, 65501, 377 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 380, 9, -1, 1, 5, 1, -1, 10, 380, 7, -1, 26, 380, 4, 
                 -1, 1, 380 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 386, 1, 385, 65501, 386 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 389, 9, -1, 1, 5, 1, -1, 10, 389, 7, -1, 26, 389, 4, 
                 -1, 1, 389 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 395, 1, 394, 65501, 395 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 398, 9, -1, 1, 5, 1, -1, 10, 398, 7, -1, 26, 398, 4, 
                 -1, 1, 398 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 404, 1, 403, 65501, 404 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 407, 9, -1, 1, 5, 1, -1, 10, 407, 7, -1, 26, 407, 4, 
                 -1, 1, 407 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 413, 1, 412, 65501, 413 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 416, 9, -1, 1, 5, 1, -1, 10, 416, 7, -1, 26, 416, 4, 
                 -1, 1, 416 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 422, 1, 421, 65501, 422 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 425, 9, -1, 1, 5, 1, -1, 10, 425, 7, -1, 26, 425, 4, 
                 -1, 1, 425 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 431, 1, 430, 65501, 431 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 434, 9, -1, 1, 5, 1, -1, 10, 434, 7, -1, 26, 434, 4, 
                 -1, 1, 434 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 440, 1, 439, 65501, 440 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 443, 9, -1, 1, 5, 1, -1, 10, 443, 7, -1, 26, 443, 4, 
                 -1, 1, 443 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 449, 1, 448, 65501, 449 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 452, 9, -1, 1, 5, 1, -1, 10, 452, 7, -1, 26, 452, 4, 
                 -1, 1, 452 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 458, 1, 457, 65501, 458 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 461, 9, -1, 1, 5, 1, -1, 10, 461, 7, -1, 26, 461, 4, 
                 -1, 1, 461 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 467, 1, 466, 65501, 467 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 470, 9, -1, 1, 5, 1, -1, 10, 470, 7, -1, 26, 470, 4, 
                 -1, 1, 470 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 476, 1, 475, 65501, 476 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 479, 9, -1, 1, 5, 1, -1, 10, 479, 7, -1, 26, 479, 4, 
                 -1, 1, 479 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 485, 1, 484, 65501, 485 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 488, 9, -1, 1, 5, 1, -1, 10, 488, 7, -1, 26, 488, 4, 
                 -1, 1, 488 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 494, 1, 493, 65501, 494 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 497, 9, -1, 1, 5, 1, -1, 10, 497, 7, -1, 26, 497, 4, 
                 -1, 1, 497 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 503, 1, 502, 65501, 503 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 506, 9, -1, 1, 5, 1, -1, 10, 506, 7, -1, 26, 506, 4, 
                 -1, 1, 506 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 512, 1, 511, 65501, 512 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 515, 9, -1, 1, 5, 1, -1, 10, 515, 7, -1, 26, 515, 4, 
                 -1, 1, 515 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 521, 1, 520, 65501, 521 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 524, 9, -1, 1, 5, 1, -1, 10, 524, 7, -1, 26, 524, 4, 
                 -1, 1, 524 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 530, 1, 529, 65501, 530 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 533, 9, -1, 1, 5, 1, -1, 10, 533, 7, -1, 26, 533, 4, 
                 -1, 1, 533 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 539, 1, 538, 65501, 539 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 542, 9, -1, 1, 5, 1, -1, 10, 542, 7, -1, 26, 542, 4, 
                 -1, 1, 542 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 548, 1, 547, 65501, 548 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 551, 9, -1, 1, 5, 1, -1, 10, 551, 7, -1, 26, 551, 4, 
                 -1, 1, 551 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 557, 1, 556, 65501, 557 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 560, 9, -1, 1, 5, 1, -1, 10, 560, 7, -1, 26, 560, 4, 
                 -1, 1, 560 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 566, 1, 565, 65501, 566 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 569, 9, -1, 1, 5, 1, -1, 10, 569, 7, -1, 26, 569, 4, 
                 -1, 1, 569 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 575, 1, 574, 65501, 575 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 578, 9, -1, 1, 5, 1, -1, 10, 578, 7, -1, 26, 578, 4, 
                 -1, 1, 578 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 584, 1, 583, 65501, 584 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 587, 9, -1, 1, 5, 1, -1, 10, 587, 7, -1, 26, 587, 4, 
                 -1, 1, 587 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 593, 1, 592, 65501, 593 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 596, 9, -1, 1, 5, 1, -1, 10, 596, 7, -1, 26, 596, 4, 
                 -1, 1, 596 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 602, 1, 601, 65501, 602 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 605, 9, -1, 1, 5, 1, -1, 10, 605, 7, -1, 26, 605, 4, 
                 -1, 1, 605 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 611, 1, 610, 65501, 611 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 614, 9, -1, 1, 5, 1, -1, 10, 614, 7, -1, 26, 614, 4, 
                 -1, 1, 614 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 620, 1, 619, 65501, 620 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 623, 9, -1, 1, 5, 1, -1, 10, 623, 7, -1, 26, 623, 4, 
                 -1, 1, 623 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 629, 1, 628, 65501, 629 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 632, 9, -1, 1, 5, 1, -1, 10, 632, 7, -1, 26, 632, 4, 
                 -1, 1, 632 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 638, 1, 637, 65501, 638 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 641, 9, -1, 1, 5, 1, -1, 10, 641, 7, -1, 26, 641, 4, 
                 -1, 1, 641 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 647, 1, 646, 65501, 647 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 650, 9, -1, 1, 5, 1, -1, 10, 650, 7, -1, 26, 650, 4, 
                 -1, 1, 650 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 656, 1, 655, 65501, 656 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 659, 9, -1, 1, 5, 1, -1, 10, 659, 7, -1, 26, 659, 4, 
                 -1, 1, 659 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 665, 1, 664, 65501, 665 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 668, 9, -1, 1, 5, 1, -1, 10, 668, 7, -1, 26, 668, 4, 
                 -1, 1, 668 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 674, 1, 673, 65501, 674 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 677, 9, -1, 1, 5, 1, -1, 10, 677, 7, -1, 26, 677, 4, 
                 -1, 1, 677 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 683, 1, 682, 65501, 683 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 686, 9, -1, 1, 5, 1, -1, 10, 686, 7, -1, 26, 686, 4, 
                 -1, 1, 686 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 692, 1, 691, 65501, 692 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 695, 9, -1, 1, 5, 1, -1, 10, 695, 7, -1, 26, 695, 4, 
                 -1, 1, 695 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 701, 1, 700, 65501, 701 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 704, 9, -1, 1, 5, 1, -1, 10, 704, 7, -1, 26, 704, 4, 
                 -1, 1, 704 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 710, 1, 709, 65501, 710 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 713, 9, -1, 1, 5, 1, -1, 10, 713, 7, -1, 26, 713, 4, 
                 -1, 1, 713 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 719, 1, 718, 65501, 719 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 722, 9, -1, 1, 5, 1, -1, 10, 722, 7, -1, 26, 722, 4, 
                 -1, 1, 722 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 728, 1, 727, 65501, 728 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 731, 9, -1, 1, 5, 1, -1, 10, 731, 7, -1, 26, 731, 4, 
                 -1, 1, 731 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 737, 1, 736, 65501, 737 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 740, 9, -1, 1, 5, 1, -1, 10, 740, 7, -1, 26, 740, 4, 
                 -1, 1, 740 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 746, 1, 745, 65501, 746 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 749, 9, -1, 1, 5, 1, -1, 10, 749, 7, -1, 26, 749, 4, 
                 -1, 1, 749 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 755, 1, 754, 65501, 755 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 758, 9, -1, 1, 5, 1, -1, 10, 758, 7, -1, 26, 758, 4, 
                 -1, 1, 758 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 764, 1, 763, 65501, 764 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 767, 9, -1, 1, 5, 1, -1, 10, 767, 7, -1, 26, 767, 4, 
                 -1, 1, 767 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 773, 1, 772, 65501, 773 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 776, 9, -1, 1, 5, 1, -1, 10, 776, 7, -1, 26, 776, 4, 
                 -1, 1, 776 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 782, 1, 781, 65501, 782 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 785, 9, -1, 1, 5, 1, -1, 10, 785, 7, -1, 26, 785, 4, 
                 -1, 1, 785 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 791, 1, 790, 65501, 791 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 794, 9, -1, 1, 5, 1, -1, 10, 794, 7, -1, 26, 794, 4, 
                 -1, 1, 794 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 800, 1, 799, 65501, 800 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 803, 9, -1, 1, 5, 1, -1, 10, 803, 7, -1, 26, 803, 4, 
                 -1, 1, 803 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 809, 1, 808, 65501, 809 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 812, 9, -1, 1, 5, 1, -1, 10, 812, 7, -1, 26, 812, 4, 
                 -1, 1, 812 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 818, 1, 817, 65501, 818 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 821, 9, -1, 1, 5, 1, -1, 10, 821, 7, -1, 26, 821, 4, 
                 -1, 1, 821 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 827, 1, 826, 65501, 827 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 830, 9, -1, 1, 5, 1, -1, 10, 830, 7, -1, 26, 830, 4, 
                 -1, 1, 830 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 836, 1, 835, 65501, 836 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 839, 9, -1, 1, 5, 1, -1, 10, 839, 7, -1, 26, 839, 4, 
                 -1, 1, 839 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 845, 1, 844, 65501, 845 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 848, 9, -1, 1, 5, 1, -1, 10, 848, 7, -1, 26, 848, 4, 
                 -1, 1, 848 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 854, 1, 853, 65501, 854 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 857, 9, -1, 1, 5, 1, -1, 10, 857, 7, -1, 26, 857, 4, 
                 -1, 1, 857 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 863, 1, 862, 65501, 863 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 866, 9, -1, 1, 5, 1, -1, 10, 866, 7, -1, 26, 866, 4, 
                 -1, 1, 866 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 872, 1, 871, 65501, 872 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 875, 9, -1, 1, 5, 1, -1, 10, 875, 7, -1, 26, 875, 4, 
                 -1, 1, 875 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 881, 1, 880, 65501, 881 ),
        unpack(  ),
        unpack(  ),
        unpack( 2, 884, 9, -1, 1, 5, 1, -1, 10, 884, 7, -1, 26, 884, 4, 
                 -1, 1, 884 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 5 ),
        unpack( 34, 890, 1, 889, 65501, 890 ),
        unpack(  ),
        unpack(  ),
        unpack( 1, -1 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, -1 ),
        unpack( 1, -1 )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 21
      

      def description
        <<-'__dfa_description__'.strip!
          203:5: (owner= ID '.' )?
        __dfa_description__
      end
    end
    class DFA28 < ANTLR3::DFA
      EOT = unpack( 11, -1 )
      EOF = unpack( 11, -1 )
      MIN = unpack( 1, 9, 10, -1 )
      MAX = unpack( 1, 110, 10, -1 )
      ACCEPT = unpack( 1, -1, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 
                       1, 8, 1, 9, 1, 10 )
      SPECIAL = unpack( 11, -1 )
      TRANSITION = [
        unpack( 2, 8, 21, -1, 1, 8, 6, -1, 1, 1, 1, 9, 1, 10, 3, -1, 1, 
                2, 1, -1, 1, 3, 22, -1, 1, 4, 2, -1, 1, 5, 1, 7, 10, -1, 
                1, 6, 24, -1, 1, 1 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 28
      

      def description
        <<-'__dfa_description__'.strip!
          1:1: Tokens options {k=1; backtrack=true; } : ( QUOTED_STRING | SL_COMMENT | ML_COMMENT | FROM | INTO | UPDATE | JOIN_CLAUSE | WS | LBR | RBR );
        __dfa_description__
      end
    end

    
    private
    
    def initialize_dfas
      super rescue nil
      @dfa21 = DFA21.new( self, 21 ) do |s|
        case s
        when 0
          look_21_2 = @input.peek
          s = -1
          if ( look_21_2.between?( 0x0, 0x21 ) || look_21_2.between?( 0x23, 0xffff ) )
            s = 7
          elsif ( look_21_2 == 0x22 )
            s = 8
          end

        when 1
          look_21_7 = @input.peek
          s = -1
          if ( look_21_7 == 0x22 )
            s = 13
          elsif ( look_21_7.between?( 0x0, 0x21 ) || look_21_7.between?( 0x23, 0xffff ) )
            s = 14
          end

        when 2
          look_21_14 = @input.peek
          s = -1
          if ( look_21_14 == 0x22 )
            s = 25
          elsif ( look_21_14.between?( 0x0, 0x21 ) || look_21_14.between?( 0x23, 0xffff ) )
            s = 26
          end

        when 3
          look_21_26 = @input.peek
          s = -1
          if ( look_21_26 == 0x22 )
            s = 34
          elsif ( look_21_26.between?( 0x0, 0x21 ) || look_21_26.between?( 0x23, 0xffff ) )
            s = 35
          end

        when 4
          look_21_35 = @input.peek
          s = -1
          if ( look_21_35 == 0x22 )
            s = 43
          elsif ( look_21_35.between?( 0x0, 0x21 ) || look_21_35.between?( 0x23, 0xffff ) )
            s = 44
          end

        when 5
          look_21_44 = @input.peek
          s = -1
          if ( look_21_44 == 0x22 )
            s = 52
          elsif ( look_21_44.between?( 0x0, 0x21 ) || look_21_44.between?( 0x23, 0xffff ) )
            s = 53
          end

        when 6
          look_21_53 = @input.peek
          s = -1
          if ( look_21_53 == 0x22 )
            s = 61
          elsif ( look_21_53.between?( 0x0, 0x21 ) || look_21_53.between?( 0x23, 0xffff ) )
            s = 62
          end

        when 7
          look_21_62 = @input.peek
          s = -1
          if ( look_21_62 == 0x22 )
            s = 70
          elsif ( look_21_62.between?( 0x0, 0x21 ) || look_21_62.between?( 0x23, 0xffff ) )
            s = 71
          end

        when 8
          look_21_71 = @input.peek
          s = -1
          if ( look_21_71 == 0x22 )
            s = 79
          elsif ( look_21_71.between?( 0x0, 0x21 ) || look_21_71.between?( 0x23, 0xffff ) )
            s = 80
          end

        when 9
          look_21_80 = @input.peek
          s = -1
          if ( look_21_80 == 0x22 )
            s = 88
          elsif ( look_21_80.between?( 0x0, 0x21 ) || look_21_80.between?( 0x23, 0xffff ) )
            s = 89
          end

        when 10
          look_21_89 = @input.peek
          s = -1
          if ( look_21_89 == 0x22 )
            s = 97
          elsif ( look_21_89.between?( 0x0, 0x21 ) || look_21_89.between?( 0x23, 0xffff ) )
            s = 98
          end

        when 11
          look_21_98 = @input.peek
          s = -1
          if ( look_21_98 == 0x22 )
            s = 106
          elsif ( look_21_98.between?( 0x0, 0x21 ) || look_21_98.between?( 0x23, 0xffff ) )
            s = 107
          end

        when 12
          look_21_107 = @input.peek
          s = -1
          if ( look_21_107 == 0x22 )
            s = 115
          elsif ( look_21_107.between?( 0x0, 0x21 ) || look_21_107.between?( 0x23, 0xffff ) )
            s = 116
          end

        when 13
          look_21_116 = @input.peek
          s = -1
          if ( look_21_116 == 0x22 )
            s = 124
          elsif ( look_21_116.between?( 0x0, 0x21 ) || look_21_116.between?( 0x23, 0xffff ) )
            s = 125
          end

        when 14
          look_21_125 = @input.peek
          s = -1
          if ( look_21_125 == 0x22 )
            s = 133
          elsif ( look_21_125.between?( 0x0, 0x21 ) || look_21_125.between?( 0x23, 0xffff ) )
            s = 134
          end

        when 15
          look_21_134 = @input.peek
          s = -1
          if ( look_21_134 == 0x22 )
            s = 142
          elsif ( look_21_134.between?( 0x0, 0x21 ) || look_21_134.between?( 0x23, 0xffff ) )
            s = 143
          end

        when 16
          look_21_143 = @input.peek
          s = -1
          if ( look_21_143 == 0x22 )
            s = 151
          elsif ( look_21_143.between?( 0x0, 0x21 ) || look_21_143.between?( 0x23, 0xffff ) )
            s = 152
          end

        when 17
          look_21_152 = @input.peek
          s = -1
          if ( look_21_152 == 0x22 )
            s = 160
          elsif ( look_21_152.between?( 0x0, 0x21 ) || look_21_152.between?( 0x23, 0xffff ) )
            s = 161
          end

        when 18
          look_21_161 = @input.peek
          s = -1
          if ( look_21_161 == 0x22 )
            s = 169
          elsif ( look_21_161.between?( 0x0, 0x21 ) || look_21_161.between?( 0x23, 0xffff ) )
            s = 170
          end

        when 19
          look_21_170 = @input.peek
          s = -1
          if ( look_21_170 == 0x22 )
            s = 178
          elsif ( look_21_170.between?( 0x0, 0x21 ) || look_21_170.between?( 0x23, 0xffff ) )
            s = 179
          end

        when 20
          look_21_179 = @input.peek
          s = -1
          if ( look_21_179 == 0x22 )
            s = 187
          elsif ( look_21_179.between?( 0x0, 0x21 ) || look_21_179.between?( 0x23, 0xffff ) )
            s = 188
          end

        when 21
          look_21_188 = @input.peek
          s = -1
          if ( look_21_188 == 0x22 )
            s = 196
          elsif ( look_21_188.between?( 0x0, 0x21 ) || look_21_188.between?( 0x23, 0xffff ) )
            s = 197
          end

        when 22
          look_21_197 = @input.peek
          s = -1
          if ( look_21_197 == 0x22 )
            s = 205
          elsif ( look_21_197.between?( 0x0, 0x21 ) || look_21_197.between?( 0x23, 0xffff ) )
            s = 206
          end

        when 23
          look_21_206 = @input.peek
          s = -1
          if ( look_21_206 == 0x22 )
            s = 214
          elsif ( look_21_206.between?( 0x0, 0x21 ) || look_21_206.between?( 0x23, 0xffff ) )
            s = 215
          end

        when 24
          look_21_215 = @input.peek
          s = -1
          if ( look_21_215 == 0x22 )
            s = 223
          elsif ( look_21_215.between?( 0x0, 0x21 ) || look_21_215.between?( 0x23, 0xffff ) )
            s = 224
          end

        when 25
          look_21_224 = @input.peek
          s = -1
          if ( look_21_224 == 0x22 )
            s = 232
          elsif ( look_21_224.between?( 0x0, 0x21 ) || look_21_224.between?( 0x23, 0xffff ) )
            s = 233
          end

        when 26
          look_21_233 = @input.peek
          s = -1
          if ( look_21_233 == 0x22 )
            s = 241
          elsif ( look_21_233.between?( 0x0, 0x21 ) || look_21_233.between?( 0x23, 0xffff ) )
            s = 242
          end

        when 27
          look_21_242 = @input.peek
          s = -1
          if ( look_21_242 == 0x22 )
            s = 250
          elsif ( look_21_242.between?( 0x0, 0x21 ) || look_21_242.between?( 0x23, 0xffff ) )
            s = 251
          end

        when 28
          look_21_251 = @input.peek
          s = -1
          if ( look_21_251 == 0x22 )
            s = 259
          elsif ( look_21_251.between?( 0x0, 0x21 ) || look_21_251.between?( 0x23, 0xffff ) )
            s = 260
          end

        when 29
          look_21_260 = @input.peek
          s = -1
          if ( look_21_260 == 0x22 )
            s = 268
          elsif ( look_21_260.between?( 0x0, 0x21 ) || look_21_260.between?( 0x23, 0xffff ) )
            s = 269
          end

        when 30
          look_21_269 = @input.peek
          s = -1
          if ( look_21_269 == 0x22 )
            s = 277
          elsif ( look_21_269.between?( 0x0, 0x21 ) || look_21_269.between?( 0x23, 0xffff ) )
            s = 278
          end

        when 31
          look_21_278 = @input.peek
          s = -1
          if ( look_21_278 == 0x22 )
            s = 286
          elsif ( look_21_278.between?( 0x0, 0x21 ) || look_21_278.between?( 0x23, 0xffff ) )
            s = 287
          end

        when 32
          look_21_287 = @input.peek
          s = -1
          if ( look_21_287 == 0x22 )
            s = 295
          elsif ( look_21_287.between?( 0x0, 0x21 ) || look_21_287.between?( 0x23, 0xffff ) )
            s = 296
          end

        when 33
          look_21_296 = @input.peek
          s = -1
          if ( look_21_296 == 0x22 )
            s = 304
          elsif ( look_21_296.between?( 0x0, 0x21 ) || look_21_296.between?( 0x23, 0xffff ) )
            s = 305
          end

        when 34
          look_21_305 = @input.peek
          s = -1
          if ( look_21_305 == 0x22 )
            s = 313
          elsif ( look_21_305.between?( 0x0, 0x21 ) || look_21_305.between?( 0x23, 0xffff ) )
            s = 314
          end

        when 35
          look_21_314 = @input.peek
          s = -1
          if ( look_21_314 == 0x22 )
            s = 322
          elsif ( look_21_314.between?( 0x0, 0x21 ) || look_21_314.between?( 0x23, 0xffff ) )
            s = 323
          end

        when 36
          look_21_323 = @input.peek
          s = -1
          if ( look_21_323 == 0x22 )
            s = 331
          elsif ( look_21_323.between?( 0x0, 0x21 ) || look_21_323.between?( 0x23, 0xffff ) )
            s = 332
          end

        when 37
          look_21_332 = @input.peek
          s = -1
          if ( look_21_332 == 0x22 )
            s = 340
          elsif ( look_21_332.between?( 0x0, 0x21 ) || look_21_332.between?( 0x23, 0xffff ) )
            s = 341
          end

        when 38
          look_21_341 = @input.peek
          s = -1
          if ( look_21_341 == 0x22 )
            s = 349
          elsif ( look_21_341.between?( 0x0, 0x21 ) || look_21_341.between?( 0x23, 0xffff ) )
            s = 350
          end

        when 39
          look_21_350 = @input.peek
          s = -1
          if ( look_21_350 == 0x22 )
            s = 358
          elsif ( look_21_350.between?( 0x0, 0x21 ) || look_21_350.between?( 0x23, 0xffff ) )
            s = 359
          end

        when 40
          look_21_359 = @input.peek
          s = -1
          if ( look_21_359 == 0x22 )
            s = 367
          elsif ( look_21_359.between?( 0x0, 0x21 ) || look_21_359.between?( 0x23, 0xffff ) )
            s = 368
          end

        when 41
          look_21_368 = @input.peek
          s = -1
          if ( look_21_368 == 0x22 )
            s = 376
          elsif ( look_21_368.between?( 0x0, 0x21 ) || look_21_368.between?( 0x23, 0xffff ) )
            s = 377
          end

        when 42
          look_21_377 = @input.peek
          s = -1
          if ( look_21_377 == 0x22 )
            s = 385
          elsif ( look_21_377.between?( 0x0, 0x21 ) || look_21_377.between?( 0x23, 0xffff ) )
            s = 386
          end

        when 43
          look_21_386 = @input.peek
          s = -1
          if ( look_21_386 == 0x22 )
            s = 394
          elsif ( look_21_386.between?( 0x0, 0x21 ) || look_21_386.between?( 0x23, 0xffff ) )
            s = 395
          end

        when 44
          look_21_395 = @input.peek
          s = -1
          if ( look_21_395 == 0x22 )
            s = 403
          elsif ( look_21_395.between?( 0x0, 0x21 ) || look_21_395.between?( 0x23, 0xffff ) )
            s = 404
          end

        when 45
          look_21_404 = @input.peek
          s = -1
          if ( look_21_404 == 0x22 )
            s = 412
          elsif ( look_21_404.between?( 0x0, 0x21 ) || look_21_404.between?( 0x23, 0xffff ) )
            s = 413
          end

        when 46
          look_21_413 = @input.peek
          s = -1
          if ( look_21_413 == 0x22 )
            s = 421
          elsif ( look_21_413.between?( 0x0, 0x21 ) || look_21_413.between?( 0x23, 0xffff ) )
            s = 422
          end

        when 47
          look_21_422 = @input.peek
          s = -1
          if ( look_21_422 == 0x22 )
            s = 430
          elsif ( look_21_422.between?( 0x0, 0x21 ) || look_21_422.between?( 0x23, 0xffff ) )
            s = 431
          end

        when 48
          look_21_431 = @input.peek
          s = -1
          if ( look_21_431 == 0x22 )
            s = 439
          elsif ( look_21_431.between?( 0x0, 0x21 ) || look_21_431.between?( 0x23, 0xffff ) )
            s = 440
          end

        when 49
          look_21_440 = @input.peek
          s = -1
          if ( look_21_440 == 0x22 )
            s = 448
          elsif ( look_21_440.between?( 0x0, 0x21 ) || look_21_440.between?( 0x23, 0xffff ) )
            s = 449
          end

        when 50
          look_21_449 = @input.peek
          s = -1
          if ( look_21_449 == 0x22 )
            s = 457
          elsif ( look_21_449.between?( 0x0, 0x21 ) || look_21_449.between?( 0x23, 0xffff ) )
            s = 458
          end

        when 51
          look_21_458 = @input.peek
          s = -1
          if ( look_21_458 == 0x22 )
            s = 466
          elsif ( look_21_458.between?( 0x0, 0x21 ) || look_21_458.between?( 0x23, 0xffff ) )
            s = 467
          end

        when 52
          look_21_467 = @input.peek
          s = -1
          if ( look_21_467 == 0x22 )
            s = 475
          elsif ( look_21_467.between?( 0x0, 0x21 ) || look_21_467.between?( 0x23, 0xffff ) )
            s = 476
          end

        when 53
          look_21_476 = @input.peek
          s = -1
          if ( look_21_476 == 0x22 )
            s = 484
          elsif ( look_21_476.between?( 0x0, 0x21 ) || look_21_476.between?( 0x23, 0xffff ) )
            s = 485
          end

        when 54
          look_21_485 = @input.peek
          s = -1
          if ( look_21_485 == 0x22 )
            s = 493
          elsif ( look_21_485.between?( 0x0, 0x21 ) || look_21_485.between?( 0x23, 0xffff ) )
            s = 494
          end

        when 55
          look_21_494 = @input.peek
          s = -1
          if ( look_21_494 == 0x22 )
            s = 502
          elsif ( look_21_494.between?( 0x0, 0x21 ) || look_21_494.between?( 0x23, 0xffff ) )
            s = 503
          end

        when 56
          look_21_503 = @input.peek
          s = -1
          if ( look_21_503 == 0x22 )
            s = 511
          elsif ( look_21_503.between?( 0x0, 0x21 ) || look_21_503.between?( 0x23, 0xffff ) )
            s = 512
          end

        when 57
          look_21_512 = @input.peek
          s = -1
          if ( look_21_512 == 0x22 )
            s = 520
          elsif ( look_21_512.between?( 0x0, 0x21 ) || look_21_512.between?( 0x23, 0xffff ) )
            s = 521
          end

        when 58
          look_21_521 = @input.peek
          s = -1
          if ( look_21_521 == 0x22 )
            s = 529
          elsif ( look_21_521.between?( 0x0, 0x21 ) || look_21_521.between?( 0x23, 0xffff ) )
            s = 530
          end

        when 59
          look_21_530 = @input.peek
          s = -1
          if ( look_21_530 == 0x22 )
            s = 538
          elsif ( look_21_530.between?( 0x0, 0x21 ) || look_21_530.between?( 0x23, 0xffff ) )
            s = 539
          end

        when 60
          look_21_539 = @input.peek
          s = -1
          if ( look_21_539 == 0x22 )
            s = 547
          elsif ( look_21_539.between?( 0x0, 0x21 ) || look_21_539.between?( 0x23, 0xffff ) )
            s = 548
          end

        when 61
          look_21_548 = @input.peek
          s = -1
          if ( look_21_548 == 0x22 )
            s = 556
          elsif ( look_21_548.between?( 0x0, 0x21 ) || look_21_548.between?( 0x23, 0xffff ) )
            s = 557
          end

        when 62
          look_21_557 = @input.peek
          s = -1
          if ( look_21_557 == 0x22 )
            s = 565
          elsif ( look_21_557.between?( 0x0, 0x21 ) || look_21_557.between?( 0x23, 0xffff ) )
            s = 566
          end

        when 63
          look_21_566 = @input.peek
          s = -1
          if ( look_21_566 == 0x22 )
            s = 574
          elsif ( look_21_566.between?( 0x0, 0x21 ) || look_21_566.between?( 0x23, 0xffff ) )
            s = 575
          end

        when 64
          look_21_575 = @input.peek
          s = -1
          if ( look_21_575 == 0x22 )
            s = 583
          elsif ( look_21_575.between?( 0x0, 0x21 ) || look_21_575.between?( 0x23, 0xffff ) )
            s = 584
          end

        when 65
          look_21_584 = @input.peek
          s = -1
          if ( look_21_584 == 0x22 )
            s = 592
          elsif ( look_21_584.between?( 0x0, 0x21 ) || look_21_584.between?( 0x23, 0xffff ) )
            s = 593
          end

        when 66
          look_21_593 = @input.peek
          s = -1
          if ( look_21_593 == 0x22 )
            s = 601
          elsif ( look_21_593.between?( 0x0, 0x21 ) || look_21_593.between?( 0x23, 0xffff ) )
            s = 602
          end

        when 67
          look_21_602 = @input.peek
          s = -1
          if ( look_21_602 == 0x22 )
            s = 610
          elsif ( look_21_602.between?( 0x0, 0x21 ) || look_21_602.between?( 0x23, 0xffff ) )
            s = 611
          end

        when 68
          look_21_611 = @input.peek
          s = -1
          if ( look_21_611 == 0x22 )
            s = 619
          elsif ( look_21_611.between?( 0x0, 0x21 ) || look_21_611.between?( 0x23, 0xffff ) )
            s = 620
          end

        when 69
          look_21_620 = @input.peek
          s = -1
          if ( look_21_620 == 0x22 )
            s = 628
          elsif ( look_21_620.between?( 0x0, 0x21 ) || look_21_620.between?( 0x23, 0xffff ) )
            s = 629
          end

        when 70
          look_21_629 = @input.peek
          s = -1
          if ( look_21_629 == 0x22 )
            s = 637
          elsif ( look_21_629.between?( 0x0, 0x21 ) || look_21_629.between?( 0x23, 0xffff ) )
            s = 638
          end

        when 71
          look_21_638 = @input.peek
          s = -1
          if ( look_21_638 == 0x22 )
            s = 646
          elsif ( look_21_638.between?( 0x0, 0x21 ) || look_21_638.between?( 0x23, 0xffff ) )
            s = 647
          end

        when 72
          look_21_647 = @input.peek
          s = -1
          if ( look_21_647 == 0x22 )
            s = 655
          elsif ( look_21_647.between?( 0x0, 0x21 ) || look_21_647.between?( 0x23, 0xffff ) )
            s = 656
          end

        when 73
          look_21_656 = @input.peek
          s = -1
          if ( look_21_656 == 0x22 )
            s = 664
          elsif ( look_21_656.between?( 0x0, 0x21 ) || look_21_656.between?( 0x23, 0xffff ) )
            s = 665
          end

        when 74
          look_21_665 = @input.peek
          s = -1
          if ( look_21_665 == 0x22 )
            s = 673
          elsif ( look_21_665.between?( 0x0, 0x21 ) || look_21_665.between?( 0x23, 0xffff ) )
            s = 674
          end

        when 75
          look_21_674 = @input.peek
          s = -1
          if ( look_21_674 == 0x22 )
            s = 682
          elsif ( look_21_674.between?( 0x0, 0x21 ) || look_21_674.between?( 0x23, 0xffff ) )
            s = 683
          end

        when 76
          look_21_683 = @input.peek
          s = -1
          if ( look_21_683 == 0x22 )
            s = 691
          elsif ( look_21_683.between?( 0x0, 0x21 ) || look_21_683.between?( 0x23, 0xffff ) )
            s = 692
          end

        when 77
          look_21_692 = @input.peek
          s = -1
          if ( look_21_692 == 0x22 )
            s = 700
          elsif ( look_21_692.between?( 0x0, 0x21 ) || look_21_692.between?( 0x23, 0xffff ) )
            s = 701
          end

        when 78
          look_21_701 = @input.peek
          s = -1
          if ( look_21_701 == 0x22 )
            s = 709
          elsif ( look_21_701.between?( 0x0, 0x21 ) || look_21_701.between?( 0x23, 0xffff ) )
            s = 710
          end

        when 79
          look_21_710 = @input.peek
          s = -1
          if ( look_21_710 == 0x22 )
            s = 718
          elsif ( look_21_710.between?( 0x0, 0x21 ) || look_21_710.between?( 0x23, 0xffff ) )
            s = 719
          end

        when 80
          look_21_719 = @input.peek
          s = -1
          if ( look_21_719 == 0x22 )
            s = 727
          elsif ( look_21_719.between?( 0x0, 0x21 ) || look_21_719.between?( 0x23, 0xffff ) )
            s = 728
          end

        when 81
          look_21_728 = @input.peek
          s = -1
          if ( look_21_728 == 0x22 )
            s = 736
          elsif ( look_21_728.between?( 0x0, 0x21 ) || look_21_728.between?( 0x23, 0xffff ) )
            s = 737
          end

        when 82
          look_21_737 = @input.peek
          s = -1
          if ( look_21_737 == 0x22 )
            s = 745
          elsif ( look_21_737.between?( 0x0, 0x21 ) || look_21_737.between?( 0x23, 0xffff ) )
            s = 746
          end

        when 83
          look_21_746 = @input.peek
          s = -1
          if ( look_21_746 == 0x22 )
            s = 754
          elsif ( look_21_746.between?( 0x0, 0x21 ) || look_21_746.between?( 0x23, 0xffff ) )
            s = 755
          end

        when 84
          look_21_755 = @input.peek
          s = -1
          if ( look_21_755 == 0x22 )
            s = 763
          elsif ( look_21_755.between?( 0x0, 0x21 ) || look_21_755.between?( 0x23, 0xffff ) )
            s = 764
          end

        when 85
          look_21_764 = @input.peek
          s = -1
          if ( look_21_764 == 0x22 )
            s = 772
          elsif ( look_21_764.between?( 0x0, 0x21 ) || look_21_764.between?( 0x23, 0xffff ) )
            s = 773
          end

        when 86
          look_21_773 = @input.peek
          s = -1
          if ( look_21_773 == 0x22 )
            s = 781
          elsif ( look_21_773.between?( 0x0, 0x21 ) || look_21_773.between?( 0x23, 0xffff ) )
            s = 782
          end

        when 87
          look_21_782 = @input.peek
          s = -1
          if ( look_21_782 == 0x22 )
            s = 790
          elsif ( look_21_782.between?( 0x0, 0x21 ) || look_21_782.between?( 0x23, 0xffff ) )
            s = 791
          end

        when 88
          look_21_791 = @input.peek
          s = -1
          if ( look_21_791 == 0x22 )
            s = 799
          elsif ( look_21_791.between?( 0x0, 0x21 ) || look_21_791.between?( 0x23, 0xffff ) )
            s = 800
          end

        when 89
          look_21_800 = @input.peek
          s = -1
          if ( look_21_800 == 0x22 )
            s = 808
          elsif ( look_21_800.between?( 0x0, 0x21 ) || look_21_800.between?( 0x23, 0xffff ) )
            s = 809
          end

        when 90
          look_21_809 = @input.peek
          s = -1
          if ( look_21_809 == 0x22 )
            s = 817
          elsif ( look_21_809.between?( 0x0, 0x21 ) || look_21_809.between?( 0x23, 0xffff ) )
            s = 818
          end

        when 91
          look_21_818 = @input.peek
          s = -1
          if ( look_21_818 == 0x22 )
            s = 826
          elsif ( look_21_818.between?( 0x0, 0x21 ) || look_21_818.between?( 0x23, 0xffff ) )
            s = 827
          end

        when 92
          look_21_827 = @input.peek
          s = -1
          if ( look_21_827 == 0x22 )
            s = 835
          elsif ( look_21_827.between?( 0x0, 0x21 ) || look_21_827.between?( 0x23, 0xffff ) )
            s = 836
          end

        when 93
          look_21_836 = @input.peek
          s = -1
          if ( look_21_836 == 0x22 )
            s = 844
          elsif ( look_21_836.between?( 0x0, 0x21 ) || look_21_836.between?( 0x23, 0xffff ) )
            s = 845
          end

        when 94
          look_21_845 = @input.peek
          s = -1
          if ( look_21_845 == 0x22 )
            s = 853
          elsif ( look_21_845.between?( 0x0, 0x21 ) || look_21_845.between?( 0x23, 0xffff ) )
            s = 854
          end

        when 95
          look_21_854 = @input.peek
          s = -1
          if ( look_21_854 == 0x22 )
            s = 862
          elsif ( look_21_854.between?( 0x0, 0x21 ) || look_21_854.between?( 0x23, 0xffff ) )
            s = 863
          end

        when 96
          look_21_863 = @input.peek
          s = -1
          if ( look_21_863 == 0x22 )
            s = 871
          elsif ( look_21_863.between?( 0x0, 0x21 ) || look_21_863.between?( 0x23, 0xffff ) )
            s = 872
          end

        when 97
          look_21_872 = @input.peek
          s = -1
          if ( look_21_872 == 0x22 )
            s = 880
          elsif ( look_21_872.between?( 0x0, 0x21 ) || look_21_872.between?( 0x23, 0xffff ) )
            s = 881
          end

        when 98
          look_21_881 = @input.peek
          s = -1
          if ( look_21_881 == 0x22 )
            s = 889
          elsif ( look_21_881.between?( 0x0, 0x21 ) || look_21_881.between?( 0x23, 0xffff ) )
            s = 890
          end

        when 99
          look_21_884 = @input.peek
          index_21_884 = @input.index
          @input.rewind( @input.last_marker, false )
          s = -1
          if ( syntactic_predicate?( :synpred31_Alias ) )
            s = 5
          elsif ( true )
            s = 4
          end
           
          @input.seek( index_21_884 )

        when 100
          look_21_889 = @input.peek
          index_21_889 = @input.index
          @input.rewind( @input.last_marker, false )
          s = -1
          if ( syntactic_predicate?( :synpred31_Alias ) )
            s = 5
          elsif ( true )
            s = 4
          end
           
          @input.seek( index_21_889 )

        when 101
          look_21_890 = @input.peek
          index_21_890 = @input.index
          @input.rewind( @input.last_marker, false )
          s = -1
          if ( syntactic_predicate?( :synpred31_Alias ) )
            s = 5
          elsif ( true )
            s = 4
          end
           
          @input.seek( index_21_890 )

        end
        
        if s < 0
          @state.backtracking > 0 and raise ANTLR3::Error::BacktrackingFailed
          nva = ANTLR3::Error::NoViableAlternative.new( @dfa21.description, 21, s, input )
          @dfa21.error( nva )
          raise nva
        end
        
        s
      end
      @dfa28 = DFA28.new( self, 28 )

    end
  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end

