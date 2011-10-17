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

    # register the proper human-readable name or literal value
    # for each token type
    #
    # this is necessary because anonymous tokens, which are
    # created from literal values in the grammar, do not
    # have descriptive names
    register_names( "DOT", "ID", "DOUBLEQUOTED_STRING", "WS", "SL_COMMENT", 
                    "ML_COMMENT", "POINT", "'CREATE'", "'OR'", "'PACKAGE'", 
                    "'IS'", "'AS'", "'TYPE'", "'TRIGGER'", "'PROCEDURE'", 
                    "'FUNCTION'", "'VIEW'" )
    
  end


  class Parser < ANTLR3::Parser
    @grammar_home = Orasource
    include ANTLR3::ASTBuilder

    RULE_METHODS = [ :start_rule, :package_spec, :package_body, :type_spec, 
                     :type_body, :trigger, :procedure, :function, :view, 
                     :oracle_object_name, :schema_name, :identifier, :keyBODY, 
                     :keyREPLACE ].freeze


    include TokenData

    begin
      generated_using( "orasource.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end

    def initialize( input, options = {} )
      super( input, options )
      @state.rule_memory = {}

      # - - - - - - begin action @parser::init - - - - - -
      # orasource.ruby.g


        @object_owner = nil
        @object_type = nil
        @object_name = nil

      # - - - - - - end action @parser::init - - - - - - -


    end

      attr_reader :object_owner, :object_type, :object_name

    	def self.describe(source)
        lexer = Orasource::Lexer.new(source.upcase, :error_output => StringIO.new)
        tokens = ANTLR3::CommonTokenStream.new(lexer)
        parser = Orasource::Parser.new(tokens, :error_output => StringIO.new)
        begin
          parser.start_rule
        rescue
          #ignore errors
        end
        return {:object_owner => parser.object_owner, 
                :object_type => parser.object_type, 
                :object_name => parser.object_name }
    	end

    # - - - - - - - - - - - - Rules - - - - - - - - - - - - -
    StartRuleReturnValue = define_return_scope 

    # 
    # parser rule start_rule
    # 
    # (in orasource.ruby.g)
    # 44:1: start_rule : 'CREATE' ( 'OR' keyREPLACE )? ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view ) ;
    # 
    def start_rule
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )
      return_value = StartRuleReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      start_rule_start_index = @input.index

      root_0 = nil
      string_literal1 = nil
      string_literal2 = nil
      keyREPLACE3 = nil
      package_spec4 = nil
      package_body5 = nil
      type_spec6 = nil
      type_body7 = nil
      trigger8 = nil
      procedure9 = nil
      function10 = nil
      view11 = nil

      tree_for_string_literal1 = nil
      tree_for_string_literal2 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 45:4: 'CREATE' ( 'OR' keyREPLACE )? ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        string_literal1 = match( T__11, TOKENS_FOLLOWING_T__11_IN_start_rule_77 )
        if @state.backtracking == 0

          tree_for_string_literal1 = @adaptor.create_with_payload( string_literal1 )
          @adaptor.add_child( root_0, tree_for_string_literal1 )

        end
        # at line 45:13: ( 'OR' keyREPLACE )?
        alt_1 = 2
        look_1_0 = @input.peek( 1 )

        if ( look_1_0 == T__12 )
          alt_1 = 1
        end
        case alt_1
        when 1
          # at line 45:15: 'OR' keyREPLACE
          string_literal2 = match( T__12, TOKENS_FOLLOWING_T__12_IN_start_rule_81 )
          if @state.backtracking == 0

            tree_for_string_literal2 = @adaptor.create_with_payload( string_literal2 )
            @adaptor.add_child( root_0, tree_for_string_literal2 )

          end
          @state.following.push( TOKENS_FOLLOWING_keyREPLACE_IN_start_rule_83 )
          keyREPLACE3 = keyREPLACE
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, keyREPLACE3.tree )
          end

        end
        # at line 46:5: ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        alt_2 = 8
        alt_2 = @dfa2.predict( @input )
        case alt_2
        when 1
          # at line 46:6: package_spec
          @state.following.push( TOKENS_FOLLOWING_package_spec_IN_start_rule_93 )
          package_spec4 = package_spec
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, package_spec4.tree )
          end

        when 2
          # at line 48:6: package_body
          @state.following.push( TOKENS_FOLLOWING_package_body_IN_start_rule_107 )
          package_body5 = package_body
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, package_body5.tree )
          end

        when 3
          # at line 50:6: type_spec
          @state.following.push( TOKENS_FOLLOWING_type_spec_IN_start_rule_121 )
          type_spec6 = type_spec
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, type_spec6.tree )
          end

        when 4
          # at line 52:6: type_body
          @state.following.push( TOKENS_FOLLOWING_type_body_IN_start_rule_135 )
          type_body7 = type_body
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, type_body7.tree )
          end

        when 5
          # at line 54:6: trigger
          @state.following.push( TOKENS_FOLLOWING_trigger_IN_start_rule_149 )
          trigger8 = trigger
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, trigger8.tree )
          end

        when 6
          # at line 56:6: procedure
          @state.following.push( TOKENS_FOLLOWING_procedure_IN_start_rule_163 )
          procedure9 = procedure
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, procedure9.tree )
          end

        when 7
          # at line 58:6: function
          @state.following.push( TOKENS_FOLLOWING_function_IN_start_rule_177 )
          function10 = function
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, function10.tree )
          end

        when 8
          # at line 60:6: view
          @state.following.push( TOKENS_FOLLOWING_view_IN_start_rule_191 )
          view11 = view
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, view11.tree )
          end

        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 1 )
        memoize( __method__, start_rule_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    PackageSpecReturnValue = define_return_scope 

    # 
    # parser rule package_spec
    # 
    # (in orasource.ruby.g)
    # 64:1: package_spec : 'PACKAGE' oracle_object_name ( 'IS' | 'AS' ) ;
    # 
    def package_spec
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )
      return_value = PackageSpecReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      package_spec_start_index = @input.index

      root_0 = nil
      string_literal12 = nil
      set14 = nil
      oracle_object_name13 = nil

      tree_for_string_literal12 = nil
      tree_for_set14 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 65:4: 'PACKAGE' oracle_object_name ( 'IS' | 'AS' )
        string_literal12 = match( T__13, TOKENS_FOLLOWING_T__13_IN_package_spec_209 )
        if @state.backtracking == 0

          tree_for_string_literal12 = @adaptor.create_with_payload( string_literal12 )
          @adaptor.add_child( root_0, tree_for_string_literal12 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_package_spec_211 )
        oracle_object_name13 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name13.tree )
        end
        set14 = @input.look
        if @input.peek( 1 ).between?( T__14, T__15 )
          @input.consume
          if @state.backtracking == 0
            @adaptor.add_child( root_0, @adaptor.create_with_payload( set14 ) )
          end
          @state.error_recovery = false
        else
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          mse = MismatchedSet( nil )
          raise mse
        end


        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'PACKAGE' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 2 )
        memoize( __method__, package_spec_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    PackageBodyReturnValue = define_return_scope 

    # 
    # parser rule package_body
    # 
    # (in orasource.ruby.g)
    # 69:1: package_body : 'PACKAGE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' ) ;
    # 
    def package_body
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )
      return_value = PackageBodyReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      package_body_start_index = @input.index

      root_0 = nil
      string_literal15 = nil
      set18 = nil
      keyBODY16 = nil
      oracle_object_name17 = nil

      tree_for_string_literal15 = nil
      tree_for_set18 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 70:4: 'PACKAGE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' )
        string_literal15 = match( T__13, TOKENS_FOLLOWING_T__13_IN_package_body_237 )
        if @state.backtracking == 0

          tree_for_string_literal15 = @adaptor.create_with_payload( string_literal15 )
          @adaptor.add_child( root_0, tree_for_string_literal15 )

        end
        # at line 70:14: ( keyBODY )
        # at line 70:16: keyBODY
        @state.following.push( TOKENS_FOLLOWING_keyBODY_IN_package_body_241 )
        keyBODY16 = keyBODY
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyBODY16.tree )
        end

        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_package_body_245 )
        oracle_object_name17 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name17.tree )
        end
        set18 = @input.look
        if @input.peek( 1 ).between?( T__14, T__15 )
          @input.consume
          if @state.backtracking == 0
            @adaptor.add_child( root_0, @adaptor.create_with_payload( set18 ) )
          end
          @state.error_recovery = false
        else
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          mse = MismatchedSet( nil )
          raise mse
        end


        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'PACKAGE_BODY' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 3 )
        memoize( __method__, package_body_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    TypeSpecReturnValue = define_return_scope 

    # 
    # parser rule type_spec
    # 
    # (in orasource.ruby.g)
    # 74:1: type_spec : 'TYPE' oracle_object_name ( 'IS' | 'AS' ) ;
    # 
    def type_spec
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )
      return_value = TypeSpecReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      type_spec_start_index = @input.index

      root_0 = nil
      string_literal19 = nil
      set21 = nil
      oracle_object_name20 = nil

      tree_for_string_literal19 = nil
      tree_for_set21 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 75:4: 'TYPE' oracle_object_name ( 'IS' | 'AS' )
        string_literal19 = match( T__16, TOKENS_FOLLOWING_T__16_IN_type_spec_270 )
        if @state.backtracking == 0

          tree_for_string_literal19 = @adaptor.create_with_payload( string_literal19 )
          @adaptor.add_child( root_0, tree_for_string_literal19 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_type_spec_272 )
        oracle_object_name20 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name20.tree )
        end
        set21 = @input.look
        if @input.peek( 1 ).between?( T__14, T__15 )
          @input.consume
          if @state.backtracking == 0
            @adaptor.add_child( root_0, @adaptor.create_with_payload( set21 ) )
          end
          @state.error_recovery = false
        else
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          mse = MismatchedSet( nil )
          raise mse
        end


        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'TYPE' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 4 )
        memoize( __method__, type_spec_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    TypeBodyReturnValue = define_return_scope 

    # 
    # parser rule type_body
    # 
    # (in orasource.ruby.g)
    # 79:1: type_body : 'TYPE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' ) ;
    # 
    def type_body
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )
      return_value = TypeBodyReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      type_body_start_index = @input.index

      root_0 = nil
      string_literal22 = nil
      set25 = nil
      keyBODY23 = nil
      oracle_object_name24 = nil

      tree_for_string_literal22 = nil
      tree_for_set25 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 80:4: 'TYPE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' )
        string_literal22 = match( T__16, TOKENS_FOLLOWING_T__16_IN_type_body_297 )
        if @state.backtracking == 0

          tree_for_string_literal22 = @adaptor.create_with_payload( string_literal22 )
          @adaptor.add_child( root_0, tree_for_string_literal22 )

        end
        # at line 80:11: ( keyBODY )
        # at line 80:13: keyBODY
        @state.following.push( TOKENS_FOLLOWING_keyBODY_IN_type_body_301 )
        keyBODY23 = keyBODY
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyBODY23.tree )
        end

        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_type_body_305 )
        oracle_object_name24 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name24.tree )
        end
        set25 = @input.look
        if @input.peek( 1 ).between?( T__14, T__15 )
          @input.consume
          if @state.backtracking == 0
            @adaptor.add_child( root_0, @adaptor.create_with_payload( set25 ) )
          end
          @state.error_recovery = false
        else
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          mse = MismatchedSet( nil )
          raise mse
        end


        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'TYPE_BODY' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 5 )
        memoize( __method__, type_body_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    TriggerReturnValue = define_return_scope 

    # 
    # parser rule trigger
    # 
    # (in orasource.ruby.g)
    # 84:1: trigger : 'TRIGGER' oracle_object_name ;
    # 
    def trigger
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )
      return_value = TriggerReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      trigger_start_index = @input.index

      root_0 = nil
      string_literal26 = nil
      oracle_object_name27 = nil

      tree_for_string_literal26 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 85:4: 'TRIGGER' oracle_object_name
        string_literal26 = match( T__17, TOKENS_FOLLOWING_T__17_IN_trigger_329 )
        if @state.backtracking == 0

          tree_for_string_literal26 = @adaptor.create_with_payload( string_literal26 )
          @adaptor.add_child( root_0, tree_for_string_literal26 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_trigger_331 )
        oracle_object_name27 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name27.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'TRIGGER' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 6 )
        memoize( __method__, trigger_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    ProcedureReturnValue = define_return_scope 

    # 
    # parser rule procedure
    # 
    # (in orasource.ruby.g)
    # 89:1: procedure : 'PROCEDURE' oracle_object_name ;
    # 
    def procedure
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )
      return_value = ProcedureReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      procedure_start_index = @input.index

      root_0 = nil
      string_literal28 = nil
      oracle_object_name29 = nil

      tree_for_string_literal28 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 90:4: 'PROCEDURE' oracle_object_name
        string_literal28 = match( T__18, TOKENS_FOLLOWING_T__18_IN_procedure_345 )
        if @state.backtracking == 0

          tree_for_string_literal28 = @adaptor.create_with_payload( string_literal28 )
          @adaptor.add_child( root_0, tree_for_string_literal28 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_procedure_347 )
        oracle_object_name29 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name29.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'PROCEDURE' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 7 )
        memoize( __method__, procedure_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    FunctionReturnValue = define_return_scope 

    # 
    # parser rule function
    # 
    # (in orasource.ruby.g)
    # 94:1: function : 'FUNCTION' oracle_object_name ;
    # 
    def function
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )
      return_value = FunctionReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      function_start_index = @input.index

      root_0 = nil
      string_literal30 = nil
      oracle_object_name31 = nil

      tree_for_string_literal30 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 95:4: 'FUNCTION' oracle_object_name
        string_literal30 = match( T__19, TOKENS_FOLLOWING_T__19_IN_function_361 )
        if @state.backtracking == 0

          tree_for_string_literal30 = @adaptor.create_with_payload( string_literal30 )
          @adaptor.add_child( root_0, tree_for_string_literal30 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_function_363 )
        oracle_object_name31 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name31.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'FUNCTION' unless @object_type  
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 8 )
        memoize( __method__, function_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    ViewReturnValue = define_return_scope 

    # 
    # parser rule view
    # 
    # (in orasource.ruby.g)
    # 99:1: view : 'VIEW' oracle_object_name ;
    # 
    def view
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )
      return_value = ViewReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      view_start_index = @input.index

      root_0 = nil
      string_literal32 = nil
      oracle_object_name33 = nil

      tree_for_string_literal32 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 100:4: 'VIEW' oracle_object_name
        string_literal32 = match( T__20, TOKENS_FOLLOWING_T__20_IN_view_377 )
        if @state.backtracking == 0

          tree_for_string_literal32 = @adaptor.create_with_payload( string_literal32 )
          @adaptor.add_child( root_0, tree_for_string_literal32 )

        end
        @state.following.push( TOKENS_FOLLOWING_oracle_object_name_IN_view_379 )
        oracle_object_name33 = oracle_object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, oracle_object_name33.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'VIEW' unless @object_type 
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 9 )
        memoize( __method__, view_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    OracleObjectNameReturnValue = define_return_scope 

    # 
    # parser rule oracle_object_name
    # 
    # (in orasource.ruby.g)
    # 104:1: oracle_object_name : ( schema_name DOT )? identifier ;
    # 
    def oracle_object_name
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )
      return_value = OracleObjectNameReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      oracle_object_name_start_index = @input.index

      root_0 = nil
      __DOT35__ = nil
      schema_name34 = nil
      identifier36 = nil

      tree_for_DOT35 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 105:4: ( schema_name DOT )? identifier
        # at line 105:4: ( schema_name DOT )?
        alt_3 = 2
        look_3_0 = @input.peek( 1 )

        if ( look_3_0.between?( ID, DOUBLEQUOTED_STRING ) )
          look_3_1 = @input.peek( 2 )

          if ( look_3_1 == DOT )
            alt_3 = 1
          end
        end
        case alt_3
        when 1
          # at line 105:6: schema_name DOT
          @state.following.push( TOKENS_FOLLOWING_schema_name_IN_oracle_object_name_395 )
          schema_name34 = schema_name
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, schema_name34.tree )
          end
          # syntactic predicate action gate test
          if @state.backtracking == 0
            # --> action
             @object_owner = ( schema_name34 && @input.to_s( schema_name34.start, schema_name34.stop ) ) unless @object_owner 
            # <-- action
          end
          __DOT35__ = match( DOT, TOKENS_FOLLOWING_DOT_IN_oracle_object_name_399 )
          if @state.backtracking == 0

            tree_for_DOT35 = @adaptor.create_with_payload( __DOT35__ )
            @adaptor.add_child( root_0, tree_for_DOT35 )

          end

        end
        @state.following.push( TOKENS_FOLLOWING_identifier_IN_oracle_object_name_406 )
        identifier36 = identifier
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, identifier36.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_name = ( identifier36 && @input.to_s( identifier36.start, identifier36.stop ) ) unless @object_name 
          # <-- action
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 10 )
        memoize( __method__, oracle_object_name_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    SchemaNameReturnValue = define_return_scope 

    # 
    # parser rule schema_name
    # 
    # (in orasource.ruby.g)
    # 109:1: schema_name : identifier ;
    # 
    def schema_name
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )
      return_value = SchemaNameReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      schema_name_start_index = @input.index

      root_0 = nil
      identifier37 = nil


      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 110:4: identifier
        @state.following.push( TOKENS_FOLLOWING_identifier_IN_schema_name_419 )
        identifier37 = identifier
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, identifier37.tree )
        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 11 )
        memoize( __method__, schema_name_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    IdentifierReturnValue = define_return_scope 

    # 
    # parser rule identifier
    # 
    # (in orasource.ruby.g)
    # 113:1: identifier : ( ID | DOUBLEQUOTED_STRING );
    # 
    def identifier
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )
      return_value = IdentifierReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      identifier_start_index = @input.index

      root_0 = nil
      set38 = nil

      tree_for_set38 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 
        set38 = @input.look
        if @input.peek( 1 ).between?( ID, DOUBLEQUOTED_STRING )
          @input.consume
          if @state.backtracking == 0
            @adaptor.add_child( root_0, @adaptor.create_with_payload( set38 ) )
          end
          @state.error_recovery = false
        else
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          mse = MismatchedSet( nil )
          raise mse
        end


        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 12 )
        memoize( __method__, identifier_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyBODYReturnValue = define_return_scope 

    # 
    # parser rule keyBODY
    # 
    # (in orasource.ruby.g)
    # 118:1: keyBODY : {...}? ID ;
    # 
    def keyBODY
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )
      return_value = KeyBODYReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyBODY_start_index = @input.index

      root_0 = nil
      __ID39__ = nil

      tree_for_ID39 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 118:36: {...}? ID
        unless ( ( self.input.look(1).text.upcase == ("BODY") ) )
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          raise FailedPredicate( "keyBODY", "self.input.look(1).text.upcase == (\"BODY\")" )
        end
        __ID39__ = match( ID, TOKENS_FOLLOWING_ID_IN_keyBODY_475 )
        if @state.backtracking == 0

          tree_for_ID39 = @adaptor.create_with_payload( __ID39__ )
          @adaptor.add_child( root_0, tree_for_ID39 )

        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 13 )
        memoize( __method__, keyBODY_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyREPLACEReturnValue = define_return_scope 

    # 
    # parser rule keyREPLACE
    # 
    # (in orasource.ruby.g)
    # 119:1: keyREPLACE : {...}? ID ;
    # 
    def keyREPLACE
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )
      return_value = KeyREPLACEReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyREPLACE_start_index = @input.index

      root_0 = nil
      __ID40__ = nil

      tree_for_ID40 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 119:36: {...}? ID
        unless ( ( self.input.look(1).text.upcase == ("REPLACE") ) )
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          raise FailedPredicate( "keyREPLACE", "self.input.look(1).text.upcase == (\"REPLACE\")" )
        end
        __ID40__ = match( ID, TOKENS_FOLLOWING_ID_IN_keyREPLACE_506 )
        if @state.backtracking == 0

          tree_for_ID40 = @adaptor.create_with_payload( __ID40__ )
          @adaptor.add_child( root_0, tree_for_ID40 )

        end
        # - - - - - - - rule clean up - - - - - - - -
        return_value.stop = @input.look( -1 )

        if @state.backtracking == 0

          return_value.tree = @adaptor.rule_post_processing( root_0 )
          @adaptor.set_token_boundaries( return_value.tree, return_value.start, return_value.stop )

        end
        success = true

      rescue ANTLR3::Error::RecognitionError => re
        report_error(re)
        recover(re)
        return_value.tree = @adaptor.create_error_node( @input, return_value.start, @input.look(-1), re )

      ensure
        # -> uncomment the next line to manually enable rule tracing
        # trace_out( __method__, 14 )
        memoize( __method__, keyREPLACE_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end



    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA2 < ANTLR3::DFA
      EOT = unpack( 13, -1 )
      EOF = unpack( 13, -1 )
      MIN = unpack( 1, 13, 2, 5, 4, -1, 1, 4, 1, -1, 1, 4, 3, -1 )
      MAX = unpack( 1, 20, 2, 6, 4, -1, 1, 15, 1, -1, 1, 15, 3, -1 )
      ACCEPT = unpack( 3, -1, 1, 5, 1, 6, 1, 7, 1, 8, 1, -1, 1, 1, 1, -1, 
                       1, 3, 1, 2, 1, 4 )
      SPECIAL = unpack( 13, -1 )
      TRANSITION = [
        unpack( 1, 1, 2, -1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6 ),
        unpack( 1, 7, 1, 8 ),
        unpack( 1, 9, 1, 10 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 8, 2, 11, 7, -1, 2, 8 ),
        unpack(  ),
        unpack( 1, 10, 2, 12, 7, -1, 2, 10 ),
        unpack(  ),
        unpack(  ),
        unpack(  )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 2
      

      def description
        <<-'__dfa_description__'.strip!
          46:5: ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        __dfa_description__
      end
    end


    private

    def initialize_dfas
      super rescue nil
      @dfa2 = DFA2.new( self, 2 )

    end
    TOKENS_FOLLOWING_T__11_IN_start_rule_77 = Set[ 12, 13, 16, 17, 18, 19, 20 ]
    TOKENS_FOLLOWING_T__12_IN_start_rule_81 = Set[ 5 ]
    TOKENS_FOLLOWING_keyREPLACE_IN_start_rule_83 = Set[ 12, 13, 16, 17, 18, 19, 20 ]
    TOKENS_FOLLOWING_package_spec_IN_start_rule_93 = Set[ 1 ]
    TOKENS_FOLLOWING_package_body_IN_start_rule_107 = Set[ 1 ]
    TOKENS_FOLLOWING_type_spec_IN_start_rule_121 = Set[ 1 ]
    TOKENS_FOLLOWING_type_body_IN_start_rule_135 = Set[ 1 ]
    TOKENS_FOLLOWING_trigger_IN_start_rule_149 = Set[ 1 ]
    TOKENS_FOLLOWING_procedure_IN_start_rule_163 = Set[ 1 ]
    TOKENS_FOLLOWING_function_IN_start_rule_177 = Set[ 1 ]
    TOKENS_FOLLOWING_view_IN_start_rule_191 = Set[ 1 ]
    TOKENS_FOLLOWING_T__13_IN_package_spec_209 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_package_spec_211 = Set[ 14, 15 ]
    TOKENS_FOLLOWING_set_IN_package_spec_213 = Set[ 1 ]
    TOKENS_FOLLOWING_T__13_IN_package_body_237 = Set[ 5 ]
    TOKENS_FOLLOWING_keyBODY_IN_package_body_241 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_package_body_245 = Set[ 14, 15 ]
    TOKENS_FOLLOWING_set_IN_package_body_247 = Set[ 1 ]
    TOKENS_FOLLOWING_T__16_IN_type_spec_270 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_type_spec_272 = Set[ 14, 15 ]
    TOKENS_FOLLOWING_set_IN_type_spec_274 = Set[ 1 ]
    TOKENS_FOLLOWING_T__16_IN_type_body_297 = Set[ 5 ]
    TOKENS_FOLLOWING_keyBODY_IN_type_body_301 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_type_body_305 = Set[ 14, 15 ]
    TOKENS_FOLLOWING_set_IN_type_body_307 = Set[ 1 ]
    TOKENS_FOLLOWING_T__17_IN_trigger_329 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_trigger_331 = Set[ 1 ]
    TOKENS_FOLLOWING_T__18_IN_procedure_345 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_procedure_347 = Set[ 1 ]
    TOKENS_FOLLOWING_T__19_IN_function_361 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_function_363 = Set[ 1 ]
    TOKENS_FOLLOWING_T__20_IN_view_377 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_oracle_object_name_IN_view_379 = Set[ 1 ]
    TOKENS_FOLLOWING_schema_name_IN_oracle_object_name_395 = Set[ 4 ]
    TOKENS_FOLLOWING_DOT_IN_oracle_object_name_399 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_identifier_IN_oracle_object_name_406 = Set[ 1 ]
    TOKENS_FOLLOWING_identifier_IN_schema_name_419 = Set[ 1 ]
    TOKENS_FOLLOWING_set_IN_identifier_0 = Set[ 1 ]
    TOKENS_FOLLOWING_ID_IN_keyBODY_475 = Set[ 1 ]
    TOKENS_FOLLOWING_ID_IN_keyREPLACE_506 = Set[ 1 ]

  end # class Parser < ANTLR3::Parser

  at_exit { Parser.main( ARGV ) } if __FILE__ == $0
end
# - - - - - - begin action @all::footer - - - - - -
# orasource.ruby.g


	end

# - - - - - - end action @all::footer - - - - - - -


