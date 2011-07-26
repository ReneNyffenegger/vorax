#!/usr/bin/env ruby
#
# /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g
# Generated at: 2011-07-25 16:32:29
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
      generated_using( "/home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "QUOTED_STRING", "SL_COMMENT", "ML_COMMENT", "FROM", 
                     "INTO", "UPDATE", "JOIN_CLAUSE", "WS", "ID", "DOUBLEQUOTED_STRING", 
                     "LBR", "RBR", "SUB_SELECT", "OBJ_ALIAS", "PLAIN_TABLE_REF", 
                     "TABLE_REFERENCE_WITH_ALIAS", "TABLE_REFERENCE" ].freeze
    RULE_METHODS = [ :quoted_string!, :sl_comment!, :ml_comment!, :from!, 
                     :into!, :update!, :join_clause!, :ws!, :id!, :doublequoted_string!, 
                     :lbr!, :rbr!, :sub_select!, :obj_alias!, :plain_table_ref!, 
                     :table_reference_with_alias!, :table_reference! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )
      # - - - - - - begin action @lexer::init - - - - - -
      # /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g


        @aliases = []
        @last_table = nil;
        @last_owner = nil;
        @last_dblink = nil;
        @last_alias = nil;

      # - - - - - - end action @lexer::init - - - - - - -

    end
    
    # - - - - - - begin action @lexer::members - - - - - -
    # /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g



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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def quoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = QUOTED_STRING
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 122:5: ( 'n' )? '\\'' ( '\\'\\'' | ~ ( '\\'' ) )* '\\''
      # at line 122:5: ( 'n' )?
      alt_1 = 2
      look_1_0 = @input.peek( 1 )

      if ( look_1_0 == 0x6e )
        alt_1 = 1
      end
      case alt_1
      when 1
        # at line 122:7: 'n'
        match( 0x6e )

      end
      match( 0x27 )
      # at line 122:19: ( '\\'\\'' | ~ ( '\\'' ) )*
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
          # at line 122:21: '\\'\\''
          match( "''" )

        when 2
          # at line 122:30: ~ ( '\\'' )
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def sl_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = SL_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 126:5: '--' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
      match( "--" )
      # at line 126:10: (~ ( '\\n' | '\\r' ) )*
      while true # decision 3
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( 0x0, 0x9 ) || look_3_0.between?( 0xb, 0xc ) || look_3_0.between?( 0xe, 0xffff ) )
          alt_3 = 1

        end
        case alt_3
        when 1
          # at line 126:10: ~ ( '\\n' | '\\r' )
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
      # at line 126:24: ( '\\r' )?
      alt_4 = 2
      look_4_0 = @input.peek( 1 )

      if ( look_4_0 == 0xd )
        alt_4 = 1
      end
      case alt_4
      when 1
        # at line 126:24: '\\r'
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def ml_comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = ML_COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 130:5: '/*' ( options {greedy=false; } : . )* '*/'
      match( "/*" )
      # at line 130:10: ( options {greedy=false; } : . )*
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
          # at line 130:38: .
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def from!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = FROM
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 134:5: 'FROM' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "FROM" )
      ws!
      table_reference!
      # at line 134:31: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 8
        alt_8 = 2
        look_8_0 = @input.peek( 1 )

        if ( look_8_0.between?( 0x9, 0xa ) || look_8_0 == 0x20 || look_8_0 == 0x2c )
          alt_8 = 1

        end
        case alt_8
        when 1
          # at line 134:32: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 134:32: ( WS )?
          alt_6 = 2
          look_6_0 = @input.peek( 1 )

          if ( look_6_0.between?( 0x9, 0xa ) || look_6_0 == 0x20 )
            alt_6 = 1
          end
          case alt_6
          when 1
            # at line 134:32: WS
            ws!

          end
          match( 0x2c )
          # at line 134:40: ( WS )?
          alt_7 = 2
          look_7_0 = @input.peek( 1 )

          if ( look_7_0.between?( 0x9, 0xa ) || look_7_0 == 0x20 )
            alt_7 = 1
          end
          case alt_7
          when 1
            # at line 134:40: WS
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def into!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      type = INTO
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 138:5: 'INTO' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "INTO" )
      ws!
      table_reference!
      # at line 138:31: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 11
        alt_11 = 2
        look_11_0 = @input.peek( 1 )

        if ( look_11_0.between?( 0x9, 0xa ) || look_11_0 == 0x20 || look_11_0 == 0x2c )
          alt_11 = 1

        end
        case alt_11
        when 1
          # at line 138:32: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 138:32: ( WS )?
          alt_9 = 2
          look_9_0 = @input.peek( 1 )

          if ( look_9_0.between?( 0x9, 0xa ) || look_9_0 == 0x20 )
            alt_9 = 1
          end
          case alt_9
          when 1
            # at line 138:32: WS
            ws!

          end
          match( 0x2c )
          # at line 138:40: ( WS )?
          alt_10 = 2
          look_10_0 = @input.peek( 1 )

          if ( look_10_0.between?( 0x9, 0xa ) || look_10_0 == 0x20 )
            alt_10 = 1
          end
          case alt_10
          when 1
            # at line 138:40: WS
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def update!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      type = UPDATE
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 142:5: 'UPDATE' WS TABLE_REFERENCE ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      match( "UPDATE" )
      ws!
      table_reference!
      # at line 142:33: ( ( WS )? ',' ( WS )? TABLE_REFERENCE )*
      while true # decision 14
        alt_14 = 2
        look_14_0 = @input.peek( 1 )

        if ( look_14_0.between?( 0x9, 0xa ) || look_14_0 == 0x20 || look_14_0 == 0x2c )
          alt_14 = 1

        end
        case alt_14
        when 1
          # at line 142:34: ( WS )? ',' ( WS )? TABLE_REFERENCE
          # at line 142:34: ( WS )?
          alt_12 = 2
          look_12_0 = @input.peek( 1 )

          if ( look_12_0.between?( 0x9, 0xa ) || look_12_0 == 0x20 )
            alt_12 = 1
          end
          case alt_12
          when 1
            # at line 142:34: WS
            ws!

          end
          match( 0x2c )
          # at line 142:42: ( WS )?
          alt_13 = 2
          look_13_0 = @input.peek( 1 )

          if ( look_13_0.between?( 0x9, 0xa ) || look_13_0 == 0x20 )
            alt_13 = 1
          end
          case alt_13
          when 1
            # at line 142:42: WS
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def join_clause!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      type = JOIN_CLAUSE
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 146:5: 'JOIN' WS TABLE_REFERENCE ( WS )?
      match( "JOIN" )
      ws!
      table_reference!
      # at line 146:31: ( WS )?
      alt_15 = 2
      look_15_0 = @input.peek( 1 )

      if ( look_15_0.between?( 0x9, 0xa ) || look_15_0 == 0x20 )
        alt_15 = 1
      end
      case alt_15
      when 1
        # at line 146:31: WS
        ws!

      end

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule ws! (WS)
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      type = WS
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 150:5: ( ' ' | '\\t' | '\\n' )+
      # at file 150:5: ( ' ' | '\\t' | '\\n' )+
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def id!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      
      # - - - - main rule block - - - -
      # at line 155:5: ( 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )* | DOUBLEQUOTED_STRING )
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
        # at line 155:7: 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
        match_range( 0x41, 0x5a )
        # at line 155:18: ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
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
        # at line 156:7: DOUBLEQUOTED_STRING
        doublequoted_string!

      end
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # lexer rule doublequoted_string! (DOUBLEQUOTED_STRING)
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def doublequoted_string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )

      
      # - - - - main rule block - - - -
      # at line 161:5: '\"' (~ ( '\"' ) )* '\"'
      match( 0x22 )
      # at line 161:9: (~ ( '\"' ) )*
      while true # decision 19
        alt_19 = 2
        look_19_0 = @input.peek( 1 )

        if ( look_19_0.between?( 0x0, 0x21 ) || look_19_0.between?( 0x23, 0xffff ) )
          alt_19 = 1

        end
        case alt_19
        when 1
          # at line 161:11: ~ ( '\"' )
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def lbr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )

      type = LBR
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 165:5: '('
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def rbr!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )

      type = RBR
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 169:5: ')'
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def sub_select!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )

      
      # - - - - main rule block - - - -
      # at line 174:5: '(' ( SUB_SELECT | ~ ( ')' ) )* ')'
      match( 0x28 )
      # at line 174:9: ( SUB_SELECT | ~ ( ')' ) )*
      while true # decision 20
        alt_20 = 3
        look_20_0 = @input.peek( 1 )

        if ( look_20_0 == 0x28 )
          alt_20 = 1
        elsif ( look_20_0.between?( 0x0, 0x27 ) || look_20_0.between?( 0x2a, 0xffff ) )
          alt_20 = 2

        end
        case alt_20
        when 1
          # at line 174:11: SUB_SELECT
          sub_select!

        when 2
          # at line 174:24: ~ ( ')' )
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def obj_alias!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )
      # - - - - label initialization - - - -
      __ID1__ = nil


      
      # - - - - main rule block - - - -
      # at line 179:5: {...}? ID
      unless ( ( (KEYS.find { |key| next_word() == key }).nil?  ) )
        @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

        raise FailedPredicate( "OBJ_ALIAS", "(KEYS.find { |key| next_word() == key }).nil? " )
      end
      __ID1___start_434 = self.character_index
      id!
      __ID1__ = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = __ID1___start_434
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def plain_table_ref!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )
      # - - - - label initialization - - - -
      owner = nil
      table = nil
      dblink = nil


      
      # - - - - main rule block - - - -
      # at line 187:5: (owner= ID '.' )? table= ID ( '@' dblink= ID )?
      # at line 187:5: (owner= ID '.' )?
      alt_21 = 2
      alt_21 = @dfa21.predict( @input )
      case alt_21
      when 1
        # at line 187:6: owner= ID '.'
        owner_start_458 = self.character_index
        id!
        owner = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = owner_start_458
          t.stop    = self.character_index - 1
        end
        match( 0x2e )

      end
      table_start_466 = self.character_index
      id!
      table = create_token do |t|
        t.input   = @input
        t.type    = ANTLR3::INVALID_TOKEN_TYPE
        t.channel = ANTLR3::DEFAULT_CHANNEL
        t.start   = table_start_466
        t.stop    = self.character_index - 1
      end
      # at line 187:30: ( '@' dblink= ID )?
      alt_22 = 2
      look_22_0 = @input.peek( 1 )

      if ( look_22_0 == 0x40 )
        alt_22 = 1
      end
      case alt_22
      when 1
        # at line 187:31: '@' dblink= ID
        match( 0x40 )
        dblink_start_473 = self.character_index
        id!
        dblink = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = dblink_start_473
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
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def table_reference_with_alias!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )

      
      # - - - - main rule block - - - -
      # at line 196:5: PLAIN_TABLE_REF WS OBJ_ALIAS
      plain_table_ref!
      ws!
      obj_alias!

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 16 )

    end

    # lexer rule table_reference! (TABLE_REFERENCE)
    # (in /home/likewise-open/FITS/alec/vorax/vorax/ruby-helper/lib/vorax/parser/alias.ruby.g)
    def table_reference!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 17 )
      # - - - - label initialization - - - -
      ss = nil


      
      # - - - - main rule block - - - -
      # at line 201:3: ( (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? ) | ( TABLE_REFERENCE_WITH_ALIAS ( WS )? ) | ( PLAIN_TABLE_REF ( WS )? ) )
      alt_27 = 3
      alt_27 = @dfa27.predict( @input )
      case alt_27
      when 1
        # at line 201:5: (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? )
        # at line 201:5: (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? )
        # at line 201:6: ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )?
        ss_start_514 = self.character_index
        sub_select!
        ss = create_token do |t|
          t.input   = @input
          t.type    = ANTLR3::INVALID_TOKEN_TYPE
          t.channel = ANTLR3::DEFAULT_CHANNEL
          t.start   = ss_start_514
          t.stop    = self.character_index - 1
        end
        # at line 201:20: ( WS )?
        alt_23 = 2
        look_23_0 = @input.peek( 1 )

        if ( look_23_0.between?( 0x9, 0xa ) || look_23_0 == 0x20 )
          alt_23 = 1
        end
        case alt_23
        when 1
          # at line 201:20: WS
          ws!

        end
        # at line 201:24: ( OBJ_ALIAS )?
        alt_24 = 2
        look_24_0 = @input.peek( 1 )

        if ( look_24_0 == 0x22 || look_24_0.between?( 0x41, 0x5a ) )
          alt_24 = 1
        end
        case alt_24
        when 1
          # at line 201:24: OBJ_ALIAS
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
        # at line 213:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
        # at line 213:5: ( TABLE_REFERENCE_WITH_ALIAS ( WS )? )
        # at line 213:6: TABLE_REFERENCE_WITH_ALIAS ( WS )?
        table_reference_with_alias!
        # at line 213:33: ( WS )?
        alt_25 = 2
        look_25_0 = @input.peek( 1 )

        if ( look_25_0.between?( 0x9, 0xa ) || look_25_0 == 0x20 )
          alt_25 = 1
        end
        case alt_25
        when 1
          # at line 213:33: WS
          ws!

        end

        # syntactic predicate action gate test
        if @state.backtracking == 1
          # --> action

                add_alias(@last_alias, @last_table, @last_owner, @last_dblink)
              
          # <-- action
        end

      when 3
        # at line 218:5: ( PLAIN_TABLE_REF ( WS )? )
        # at line 218:5: ( PLAIN_TABLE_REF ( WS )? )
        # at line 218:6: PLAIN_TABLE_REF ( WS )?
        plain_table_ref!
        # at line 218:22: ( WS )?
        alt_26 = 2
        look_26_0 = @input.peek( 1 )

        if ( look_26_0.between?( 0x9, 0xa ) || look_26_0 == 0x20 )
          alt_26 = 1
        end
        case alt_26
        when 1
          # at line 218:22: WS
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

    
    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA21 < ANTLR3::DFA
      EOT = unpack( 1, -1, 1, 4, 1, -1, 1, 4, 3, -1, 1, 4 )
      EOF = unpack( 8, -1 )
      MIN = unpack( 1, 34, 1, 35, 1, 0, 1, 35, 2, -1, 1, 0, 1, 46 )
      MAX = unpack( 1, 90, 1, 95, 1, -1, 1, 95, 2, -1, 1, -1, 1, 46 )
      ACCEPT = unpack( 4, -1, 1, 2, 1, 1, 2, -1 )
      SPECIAL = unpack( 2, -1, 1, 0, 3, -1, 1, 1, 1, -1 )
      TRANSITION = [
        unpack( 1, 2, 30, -1, 26, 1 ),
        unpack( 2, 3, 9, -1, 1, 5, 1, -1, 10, 3, 7, -1, 26, 3, 4, -1, 1, 
                 3 ),
        unpack( 34, 6, 1, 7, 65501, 6 ),
        unpack( 2, 3, 9, -1, 1, 5, 1, -1, 10, 3, 7, -1, 26, 3, 4, -1, 1, 
                 3 ),
        unpack(  ),
        unpack(  ),
        unpack( 34, 6, 1, 7, 65501, 6 ),
        unpack( 1, 5 )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 21
      

      def description
        <<-'__dfa_description__'.strip!
          187:5: (owner= ID '.' )?
        __dfa_description__
      end
    end
    class DFA27 < ANTLR3::DFA
      EOT = unpack( 2, -1, 1, 5, 1, -1, 1, 5, 3, -1, 1, 5, 1, -1, 2, 5, 
                    1, -1, 1, 5, 2, -1, 1, 5, 1, -1, 2, 5, 1, -1, 1, 5 )
      EOF = unpack( 22, -1 )
      MIN = unpack( 1, 34, 1, -1, 1, 9, 1, 0, 1, 9, 1, -1, 2, 34, 1, 9, 
                    1, 0, 2, 9, 1, 0, 1, 9, 1, 0, 1, -1, 1, 9, 1, 0, 2, 
                    9, 1, 0, 1, 9 )
      MAX = unpack( 1, 90, 1, -1, 1, 95, 1, -1, 1, 95, 1, -1, 3, 90, 1, 
                    -1, 1, 64, 1, 95, 1, -1, 1, 95, 1, -1, 1, -1, 1, 95, 
                    1, -1, 1, 64, 1, 95, 1, -1, 1, 32 )
      ACCEPT = unpack( 1, -1, 1, 1, 3, -1, 1, 3, 9, -1, 1, 2, 6, -1 )
      SPECIAL = unpack( 3, -1, 1, 3, 5, -1, 1, 2, 2, -1, 1, 1, 1, -1, 1, 
                        0, 2, -1, 1, 5, 2, -1, 1, 4, 1, -1 )
      TRANSITION = [
        unpack( 1, 3, 5, -1, 1, 1, 24, -1, 26, 2 ),
        unpack(  ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 4, 9, -1, 1, 6, 1, -1, 10, 
                 4, 6, -1, 1, 7, 26, 4, 4, -1, 1, 4 ),
        unpack( 34, 9, 1, 10, 65501, 9 ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 4, 9, -1, 1, 6, 1, -1, 10, 
                 4, 6, -1, 1, 7, 26, 4, 4, -1, 1, 4 ),
        unpack(  ),
        unpack( 1, 12, 30, -1, 26, 11 ),
        unpack( 1, 14, 30, -1, 26, 13 ),
        unpack( 2, 8, 21, -1, 1, 8, 1, -1, 1, 15, 30, -1, 26, 15 ),
        unpack( 34, 9, 1, 10, 65501, 9 ),
        unpack( 2, 8, 21, -1, 1, 8, 13, -1, 1, 6, 17, -1, 1, 7 ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 16, 11, -1, 10, 16, 6, -1, 
                 1, 7, 26, 16, 4, -1, 1, 16 ),
        unpack( 34, 17, 1, 18, 65501, 17 ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 19, 11, -1, 10, 19, 7, -1, 
                 26, 19, 4, -1, 1, 19 ),
        unpack( 34, 20, 1, 21, 65501, 20 ),
        unpack(  ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 16, 11, -1, 10, 16, 6, -1, 
                 1, 7, 26, 16, 4, -1, 1, 16 ),
        unpack( 34, 17, 1, 18, 65501, 17 ),
        unpack( 2, 8, 21, -1, 1, 8, 31, -1, 1, 7 ),
        unpack( 2, 8, 21, -1, 1, 8, 2, -1, 2, 19, 11, -1, 10, 19, 7, -1, 
                 26, 19, 4, -1, 1, 19 ),
        unpack( 34, 20, 1, 21, 65501, 20 ),
        unpack( 2, 8, 21, -1, 1, 8 )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 27
      

      def description
        <<-'__dfa_description__'.strip!
          199:1: fragment TABLE_REFERENCE : ( (ss= SUB_SELECT ( WS )? ( OBJ_ALIAS )? ) | ( TABLE_REFERENCE_WITH_ALIAS ( WS )? ) | ( PLAIN_TABLE_REF ( WS )? ) );
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
            s = 6
          elsif ( look_21_2 == 0x22 )
            s = 7
          end

        when 1
          look_21_6 = @input.peek
          s = -1
          if ( look_21_6 == 0x22 )
            s = 7
          elsif ( look_21_6.between?( 0x0, 0x21 ) || look_21_6.between?( 0x23, 0xffff ) )
            s = 6
          end

        end
        
        if s < 0
          @state.backtracking > 0 and raise ANTLR3::Error::BacktrackingFailed
          nva = ANTLR3::Error::NoViableAlternative.new( @dfa21.description, 21, s, input )
          @dfa21.error( nva )
          raise nva
        end
        
        s
      end
      @dfa27 = DFA27.new( self, 27 ) do |s|
        case s
        when 0
          look_27_14 = @input.peek
          s = -1
          if ( look_27_14.between?( 0x0, 0x21 ) || look_27_14.between?( 0x23, 0xffff ) )
            s = 20
          elsif ( look_27_14 == 0x22 )
            s = 21
          end

        when 1
          look_27_12 = @input.peek
          s = -1
          if ( look_27_12.between?( 0x0, 0x21 ) || look_27_12.between?( 0x23, 0xffff ) )
            s = 17
          elsif ( look_27_12 == 0x22 )
            s = 18
          end

        when 2
          look_27_9 = @input.peek
          s = -1
          if ( look_27_9 == 0x22 )
            s = 10
          elsif ( look_27_9.between?( 0x0, 0x21 ) || look_27_9.between?( 0x23, 0xffff ) )
            s = 9
          end

        when 3
          look_27_3 = @input.peek
          s = -1
          if ( look_27_3.between?( 0x0, 0x21 ) || look_27_3.between?( 0x23, 0xffff ) )
            s = 9
          elsif ( look_27_3 == 0x22 )
            s = 10
          end

        when 4
          look_27_20 = @input.peek
          s = -1
          if ( look_27_20 == 0x22 )
            s = 21
          elsif ( look_27_20.between?( 0x0, 0x21 ) || look_27_20.between?( 0x23, 0xffff ) )
            s = 20
          end

        when 5
          look_27_17 = @input.peek
          s = -1
          if ( look_27_17 == 0x22 )
            s = 18
          elsif ( look_27_17.between?( 0x0, 0x21 ) || look_27_17.between?( 0x23, 0xffff ) )
            s = 17
          end

        end
        
        if s < 0
          @state.backtracking > 0 and raise ANTLR3::Error::BacktrackingFailed
          nva = ANTLR3::Error::NoViableAlternative.new( @dfa27.description, 27, s, input )
          @dfa27.error( nva )
          raise nva
        end
        
        s
      end
      @dfa28 = DFA28.new( self, 28 )

    end
  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end

