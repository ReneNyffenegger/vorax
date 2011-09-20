#!/usr/bin/env ruby
#
# source.ruby.g
# --
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jul 31, 2010 19:34:52
# Ruby runtime library version: 1.8.11
# Input grammar file: source.ruby.g
# Generated at: 2011-09-20 23:29:23
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


module Source
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
                    "ML_COMMENT", "POINT", "'CREATE'", "'OR'", "'IS'", "'AS'", 
                    "'FUNCTION'", "'PACKAGE'", "'PROCEDURE'", "'TYPE'", 
                    "'TRIGGER'", "'VIEW'" )
    
  end


  class Parser < ANTLR3::Parser
    @grammar_home = Source
    include ANTLR3::ASTBuilder

    RULE_METHODS = [ :start_rule, :package_spec, :package_body, :type_spec, 
                     :type_body, :trigger, :procedure, :function, :view, 
                     :object_name, :schema_name, :identifier, :keyBODY, 
                     :keyFUNCTION, :keyPACKAGE, :keyPROCEDURE, :keyTYPE, 
                     :keyTRIGGER, :keyVIEW, :keyREPLACE ].freeze


    include TokenData

    begin
      generated_using( "source.ruby.g", "3.2.1-SNAPSHOT Jul 31, 2010 19:34:52", "1.8.11" )
    rescue NoMethodError => error
      # ignore
    end

    def initialize( input, options = {} )
      super( input, options )
      @state.rule_memory = {}

      # - - - - - - begin action @parser::init - - - - - -
      # source.ruby.g


        @object_owner = ''
        @object_type = ''
        @object_name = ''

      # - - - - - - end action @parser::init - - - - - - -


    end

      attr_reader :object_owner, :object_type, :object_name

    # - - - - - - - - - - - - Rules - - - - - - - - - - - - -
    StartRuleReturnValue = define_return_scope 

    # 
    # parser rule start_rule
    # 
    # (in source.ruby.g)
    # 21:1: start_rule : 'CREATE' ( 'OR' keyREPLACE )? ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view ) ;
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


        # at line 22:4: 'CREATE' ( 'OR' keyREPLACE )? ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        string_literal1 = match( T__11, TOKENS_FOLLOWING_T__11_IN_start_rule_58 )
        if @state.backtracking == 0

          tree_for_string_literal1 = @adaptor.create_with_payload( string_literal1 )
          @adaptor.add_child( root_0, tree_for_string_literal1 )

        end
        # at line 22:13: ( 'OR' keyREPLACE )?
        alt_1 = 2
        look_1_0 = @input.peek( 1 )

        if ( look_1_0 == T__12 )
          alt_1 = 1
        end
        case alt_1
        when 1
          # at line 22:15: 'OR' keyREPLACE
          string_literal2 = match( T__12, TOKENS_FOLLOWING_T__12_IN_start_rule_62 )
          if @state.backtracking == 0

            tree_for_string_literal2 = @adaptor.create_with_payload( string_literal2 )
            @adaptor.add_child( root_0, tree_for_string_literal2 )

          end
          @state.following.push( TOKENS_FOLLOWING_keyREPLACE_IN_start_rule_64 )
          keyREPLACE3 = keyREPLACE
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, keyREPLACE3.tree )
          end

        end
        # at line 23:5: ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        alt_2 = 8
        alt_2 = @dfa2.predict( @input )
        case alt_2
        when 1
          # at line 23:6: package_spec
          @state.following.push( TOKENS_FOLLOWING_package_spec_IN_start_rule_74 )
          package_spec4 = package_spec
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, package_spec4.tree )
          end

        when 2
          # at line 25:6: package_body
          @state.following.push( TOKENS_FOLLOWING_package_body_IN_start_rule_88 )
          package_body5 = package_body
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, package_body5.tree )
          end

        when 3
          # at line 27:6: type_spec
          @state.following.push( TOKENS_FOLLOWING_type_spec_IN_start_rule_102 )
          type_spec6 = type_spec
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, type_spec6.tree )
          end

        when 4
          # at line 29:6: type_body
          @state.following.push( TOKENS_FOLLOWING_type_body_IN_start_rule_116 )
          type_body7 = type_body
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, type_body7.tree )
          end

        when 5
          # at line 31:6: trigger
          @state.following.push( TOKENS_FOLLOWING_trigger_IN_start_rule_130 )
          trigger8 = trigger
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, trigger8.tree )
          end

        when 6
          # at line 33:6: procedure
          @state.following.push( TOKENS_FOLLOWING_procedure_IN_start_rule_144 )
          procedure9 = procedure
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, procedure9.tree )
          end

        when 7
          # at line 35:6: function
          @state.following.push( TOKENS_FOLLOWING_function_IN_start_rule_158 )
          function10 = function
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, function10.tree )
          end

        when 8
          # at line 37:6: view
          @state.following.push( TOKENS_FOLLOWING_view_IN_start_rule_172 )
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
    # (in source.ruby.g)
    # 41:1: package_spec : keyPACKAGE object_name ( 'IS' | 'AS' ) ;
    # 
    def package_spec
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )
      return_value = PackageSpecReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      package_spec_start_index = @input.index

      root_0 = nil
      set14 = nil
      keyPACKAGE12 = nil
      object_name13 = nil

      tree_for_set14 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 42:4: keyPACKAGE object_name ( 'IS' | 'AS' )
        @state.following.push( TOKENS_FOLLOWING_keyPACKAGE_IN_package_spec_190 )
        keyPACKAGE12 = keyPACKAGE
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyPACKAGE12.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_package_spec_192 )
        object_name13 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name13.tree )
        end
        set14 = @input.look
        if @input.peek( 1 ).between?( T__13, T__14 )
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
           @object_type = 'PACKAGE' 
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
    # (in source.ruby.g)
    # 46:1: package_body : keyPACKAGE ( keyBODY ) object_name ( 'IS' | 'AS' ) ;
    # 
    def package_body
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )
      return_value = PackageBodyReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      package_body_start_index = @input.index

      root_0 = nil
      set18 = nil
      keyPACKAGE15 = nil
      keyBODY16 = nil
      object_name17 = nil

      tree_for_set18 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 47:4: keyPACKAGE ( keyBODY ) object_name ( 'IS' | 'AS' )
        @state.following.push( TOKENS_FOLLOWING_keyPACKAGE_IN_package_body_218 )
        keyPACKAGE15 = keyPACKAGE
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyPACKAGE15.tree )
        end
        # at line 47:15: ( keyBODY )
        # at line 47:17: keyBODY
        @state.following.push( TOKENS_FOLLOWING_keyBODY_IN_package_body_222 )
        keyBODY16 = keyBODY
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyBODY16.tree )
        end

        @state.following.push( TOKENS_FOLLOWING_object_name_IN_package_body_226 )
        object_name17 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name17.tree )
        end
        set18 = @input.look
        if @input.peek( 1 ).between?( T__13, T__14 )
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
           @object_type = 'PACKAGE BODY' 
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
    # (in source.ruby.g)
    # 51:1: type_spec : keyTYPE object_name ( 'IS' | 'AS' ) ;
    # 
    def type_spec
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )
      return_value = TypeSpecReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      type_spec_start_index = @input.index

      root_0 = nil
      set21 = nil
      keyTYPE19 = nil
      object_name20 = nil

      tree_for_set21 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 52:4: keyTYPE object_name ( 'IS' | 'AS' )
        @state.following.push( TOKENS_FOLLOWING_keyTYPE_IN_type_spec_251 )
        keyTYPE19 = keyTYPE
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyTYPE19.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_type_spec_253 )
        object_name20 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name20.tree )
        end
        set21 = @input.look
        if @input.peek( 1 ).between?( T__13, T__14 )
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
           @object_type = 'TYPE' 
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
    # (in source.ruby.g)
    # 56:1: type_body : keyTYPE ( keyBODY ) object_name ( 'IS' | 'AS' ) ;
    # 
    def type_body
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )
      return_value = TypeBodyReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      type_body_start_index = @input.index

      root_0 = nil
      set25 = nil
      keyTYPE22 = nil
      keyBODY23 = nil
      object_name24 = nil

      tree_for_set25 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 57:4: keyTYPE ( keyBODY ) object_name ( 'IS' | 'AS' )
        @state.following.push( TOKENS_FOLLOWING_keyTYPE_IN_type_body_278 )
        keyTYPE22 = keyTYPE
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyTYPE22.tree )
        end
        # at line 57:12: ( keyBODY )
        # at line 57:14: keyBODY
        @state.following.push( TOKENS_FOLLOWING_keyBODY_IN_type_body_282 )
        keyBODY23 = keyBODY
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyBODY23.tree )
        end

        @state.following.push( TOKENS_FOLLOWING_object_name_IN_type_body_286 )
        object_name24 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name24.tree )
        end
        set25 = @input.look
        if @input.peek( 1 ).between?( T__13, T__14 )
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
           @object_type = 'TYPE BODY' 
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
    # (in source.ruby.g)
    # 61:1: trigger : keyTRIGGER object_name ;
    # 
    def trigger
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )
      return_value = TriggerReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      trigger_start_index = @input.index

      root_0 = nil
      keyTRIGGER26 = nil
      object_name27 = nil


      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 62:4: keyTRIGGER object_name
        @state.following.push( TOKENS_FOLLOWING_keyTRIGGER_IN_trigger_310 )
        keyTRIGGER26 = keyTRIGGER
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyTRIGGER26.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_trigger_312 )
        object_name27 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name27.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'TRIGGER' 
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
    # (in source.ruby.g)
    # 66:1: procedure : keyPROCEDURE object_name ;
    # 
    def procedure
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )
      return_value = ProcedureReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      procedure_start_index = @input.index

      root_0 = nil
      keyPROCEDURE28 = nil
      object_name29 = nil


      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 67:4: keyPROCEDURE object_name
        @state.following.push( TOKENS_FOLLOWING_keyPROCEDURE_IN_procedure_326 )
        keyPROCEDURE28 = keyPROCEDURE
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyPROCEDURE28.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_procedure_328 )
        object_name29 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name29.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'PROCEDURE' 
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
    # (in source.ruby.g)
    # 71:1: function : keyFUNCTION object_name ;
    # 
    def function
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )
      return_value = FunctionReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      function_start_index = @input.index

      root_0 = nil
      keyFUNCTION30 = nil
      object_name31 = nil


      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 72:4: keyFUNCTION object_name
        @state.following.push( TOKENS_FOLLOWING_keyFUNCTION_IN_function_342 )
        keyFUNCTION30 = keyFUNCTION
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyFUNCTION30.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_function_344 )
        object_name31 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name31.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'FUNCTION' 
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
    # (in source.ruby.g)
    # 76:1: view : keyVIEW object_name ;
    # 
    def view
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )
      return_value = ViewReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      view_start_index = @input.index

      root_0 = nil
      keyVIEW32 = nil
      object_name33 = nil


      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 77:4: keyVIEW object_name
        @state.following.push( TOKENS_FOLLOWING_keyVIEW_IN_view_358 )
        keyVIEW32 = keyVIEW
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, keyVIEW32.tree )
        end
        @state.following.push( TOKENS_FOLLOWING_object_name_IN_view_360 )
        object_name33 = object_name
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, object_name33.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_type = 'VIEW' 
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

    ObjectNameReturnValue = define_return_scope 

    # 
    # parser rule object_name
    # 
    # (in source.ruby.g)
    # 81:1: object_name : ( schema_name DOT )? identifier ;
    # 
    def object_name
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )
      return_value = ObjectNameReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      object_name_start_index = @input.index

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


        # at line 82:4: ( schema_name DOT )? identifier
        # at line 82:4: ( schema_name DOT )?
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
          # at line 82:6: schema_name DOT
          @state.following.push( TOKENS_FOLLOWING_schema_name_IN_object_name_376 )
          schema_name34 = schema_name
          @state.following.pop
          if @state.backtracking == 0
            @adaptor.add_child( root_0, schema_name34.tree )
          end
          # syntactic predicate action gate test
          if @state.backtracking == 0
            # --> action
             @object_owner = ( schema_name34 && @input.to_s( schema_name34.start, schema_name34.stop ) ) 
            # <-- action
          end
          __DOT35__ = match( DOT, TOKENS_FOLLOWING_DOT_IN_object_name_380 )
          if @state.backtracking == 0

            tree_for_DOT35 = @adaptor.create_with_payload( __DOT35__ )
            @adaptor.add_child( root_0, tree_for_DOT35 )

          end

        end
        @state.following.push( TOKENS_FOLLOWING_identifier_IN_object_name_387 )
        identifier36 = identifier
        @state.following.pop
        if @state.backtracking == 0
          @adaptor.add_child( root_0, identifier36.tree )
        end
        # syntactic predicate action gate test
        if @state.backtracking == 0
          # --> action
           @object_name = ( identifier36 && @input.to_s( identifier36.start, identifier36.stop ) ) 
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
        memoize( __method__, object_name_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    SchemaNameReturnValue = define_return_scope 

    # 
    # parser rule schema_name
    # 
    # (in source.ruby.g)
    # 86:1: schema_name : identifier ;
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


        # at line 87:4: identifier
        @state.following.push( TOKENS_FOLLOWING_identifier_IN_schema_name_400 )
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
    # (in source.ruby.g)
    # 90:1: identifier : ( ID | DOUBLEQUOTED_STRING );
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
    # (in source.ruby.g)
    # 95:1: keyBODY : {...}? ID ;
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


        # at line 95:36: {...}? ID
        unless ( ( self.input.look(1).text.upcase == ("BODY") ) )
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          raise FailedPredicate( "keyBODY", "self.input.look(1).text.upcase == (\"BODY\")" )
        end
        __ID39__ = match( ID, TOKENS_FOLLOWING_ID_IN_keyBODY_456 )
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

    KeyFUNCTIONReturnValue = define_return_scope 

    # 
    # parser rule keyFUNCTION
    # 
    # (in source.ruby.g)
    # 96:1: keyFUNCTION : 'FUNCTION' ;
    # 
    def keyFUNCTION
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )
      return_value = KeyFUNCTIONReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyFUNCTION_start_index = @input.index

      root_0 = nil
      string_literal40 = nil

      tree_for_string_literal40 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 96:36: 'FUNCTION'
        string_literal40 = match( T__15, TOKENS_FOLLOWING_T__15_IN_keyFUNCTION_484 )
        if @state.backtracking == 0

          tree_for_string_literal40 = @adaptor.create_with_payload( string_literal40 )
          @adaptor.add_child( root_0, tree_for_string_literal40 )

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
        memoize( __method__, keyFUNCTION_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyPACKAGEReturnValue = define_return_scope 

    # 
    # parser rule keyPACKAGE
    # 
    # (in source.ruby.g)
    # 97:1: keyPACKAGE : 'PACKAGE' ;
    # 
    def keyPACKAGE
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )
      return_value = KeyPACKAGEReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyPACKAGE_start_index = @input.index

      root_0 = nil
      string_literal41 = nil

      tree_for_string_literal41 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 97:36: 'PACKAGE'
        string_literal41 = match( T__16, TOKENS_FOLLOWING_T__16_IN_keyPACKAGE_513 )
        if @state.backtracking == 0

          tree_for_string_literal41 = @adaptor.create_with_payload( string_literal41 )
          @adaptor.add_child( root_0, tree_for_string_literal41 )

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
        # trace_out( __method__, 15 )
        memoize( __method__, keyPACKAGE_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyPROCEDUREReturnValue = define_return_scope 

    # 
    # parser rule keyPROCEDURE
    # 
    # (in source.ruby.g)
    # 98:1: keyPROCEDURE : 'PROCEDURE' ;
    # 
    def keyPROCEDURE
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )
      return_value = KeyPROCEDUREReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyPROCEDURE_start_index = @input.index

      root_0 = nil
      string_literal42 = nil

      tree_for_string_literal42 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 98:36: 'PROCEDURE'
        string_literal42 = match( T__17, TOKENS_FOLLOWING_T__17_IN_keyPROCEDURE_540 )
        if @state.backtracking == 0

          tree_for_string_literal42 = @adaptor.create_with_payload( string_literal42 )
          @adaptor.add_child( root_0, tree_for_string_literal42 )

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
        # trace_out( __method__, 16 )
        memoize( __method__, keyPROCEDURE_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyTYPEReturnValue = define_return_scope 

    # 
    # parser rule keyTYPE
    # 
    # (in source.ruby.g)
    # 99:1: keyTYPE : 'TYPE' ;
    # 
    def keyTYPE
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 17 )
      return_value = KeyTYPEReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyTYPE_start_index = @input.index

      root_0 = nil
      string_literal43 = nil

      tree_for_string_literal43 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 99:36: 'TYPE'
        string_literal43 = match( T__18, TOKENS_FOLLOWING_T__18_IN_keyTYPE_572 )
        if @state.backtracking == 0

          tree_for_string_literal43 = @adaptor.create_with_payload( string_literal43 )
          @adaptor.add_child( root_0, tree_for_string_literal43 )

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
        # trace_out( __method__, 17 )
        memoize( __method__, keyTYPE_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyTRIGGERReturnValue = define_return_scope 

    # 
    # parser rule keyTRIGGER
    # 
    # (in source.ruby.g)
    # 100:1: keyTRIGGER : 'TRIGGER' ;
    # 
    def keyTRIGGER
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 18 )
      return_value = KeyTRIGGERReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyTRIGGER_start_index = @input.index

      root_0 = nil
      string_literal44 = nil

      tree_for_string_literal44 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 100:36: 'TRIGGER'
        string_literal44 = match( T__19, TOKENS_FOLLOWING_T__19_IN_keyTRIGGER_602 )
        if @state.backtracking == 0

          tree_for_string_literal44 = @adaptor.create_with_payload( string_literal44 )
          @adaptor.add_child( root_0, tree_for_string_literal44 )

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
        # trace_out( __method__, 18 )
        memoize( __method__, keyTRIGGER_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyVIEWReturnValue = define_return_scope 

    # 
    # parser rule keyVIEW
    # 
    # (in source.ruby.g)
    # 101:1: keyVIEW : 'VIEW' ;
    # 
    def keyVIEW
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 19 )
      return_value = KeyVIEWReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyVIEW_start_index = @input.index

      root_0 = nil
      string_literal45 = nil

      tree_for_string_literal45 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 101:36: 'VIEW'
        string_literal45 = match( T__20, TOKENS_FOLLOWING_T__20_IN_keyVIEW_635 )
        if @state.backtracking == 0

          tree_for_string_literal45 = @adaptor.create_with_payload( string_literal45 )
          @adaptor.add_child( root_0, tree_for_string_literal45 )

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
        # trace_out( __method__, 19 )
        memoize( __method__, keyVIEW_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end

    KeyREPLACEReturnValue = define_return_scope 

    # 
    # parser rule keyREPLACE
    # 
    # (in source.ruby.g)
    # 102:1: keyREPLACE : {...}? ID ;
    # 
    def keyREPLACE
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 20 )
      return_value = KeyREPLACEReturnValue.new

      # $rule.start = the first token seen before matching
      return_value.start = @input.look
      keyREPLACE_start_index = @input.index

      root_0 = nil
      __ID46__ = nil

      tree_for_ID46 = nil

      success = false # flag used for memoization

      begin
        # rule memoization
        if @state.backtracking > 0 and already_parsed_rule?( __method__ )
          success = true
          return return_value
        end
        root_0 = @adaptor.create_flat_list


        # at line 102:36: {...}? ID
        unless ( ( self.input.look(1).text.upcase == ("REPLACE") ) )
          @state.backtracking > 0 and raise( ANTLR3::Error::BacktrackingFailed )

          raise FailedPredicate( "keyREPLACE", "self.input.look(1).text.upcase == (\"REPLACE\")" )
        end
        __ID46__ = match( ID, TOKENS_FOLLOWING_ID_IN_keyREPLACE_667 )
        if @state.backtracking == 0

          tree_for_ID46 = @adaptor.create_with_payload( __ID46__ )
          @adaptor.add_child( root_0, tree_for_ID46 )

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
        # trace_out( __method__, 20 )
        memoize( __method__, keyREPLACE_start_index, success ) if @state.backtracking > 0

      end
      
      return return_value
    end



    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA2 < ANTLR3::DFA
      EOT = unpack( 13, -1 )
      EOF = unpack( 13, -1 )
      MIN = unpack( 1, 15, 2, 5, 4, -1, 1, 4, 1, -1, 1, 4, 3, -1 )
      MAX = unpack( 1, 20, 2, 6, 4, -1, 1, 14, 1, -1, 1, 14, 3, -1 )
      ACCEPT = unpack( 3, -1, 1, 5, 1, 6, 1, 7, 1, 8, 1, -1, 1, 1, 1, -1, 
                       1, 3, 1, 2, 1, 4 )
      SPECIAL = unpack( 13, -1 )
      TRANSITION = [
        unpack( 1, 5, 1, 1, 1, 4, 1, 2, 1, 3, 1, 6 ),
        unpack( 1, 7, 1, 8 ),
        unpack( 1, 9, 1, 10 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 8, 2, 11, 6, -1, 2, 8 ),
        unpack(  ),
        unpack( 1, 10, 2, 12, 6, -1, 2, 10 ),
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
          23:5: ( package_spec | package_body | type_spec | type_body | trigger | procedure | function | view )
        __dfa_description__
      end
    end


    private

    def initialize_dfas
      super rescue nil
      @dfa2 = DFA2.new( self, 2 )

    end
    TOKENS_FOLLOWING_T__11_IN_start_rule_58 = Set[ 12, 15, 16, 17, 18, 19, 20 ]
    TOKENS_FOLLOWING_T__12_IN_start_rule_62 = Set[ 5 ]
    TOKENS_FOLLOWING_keyREPLACE_IN_start_rule_64 = Set[ 12, 15, 16, 17, 18, 19, 20 ]
    TOKENS_FOLLOWING_package_spec_IN_start_rule_74 = Set[ 1 ]
    TOKENS_FOLLOWING_package_body_IN_start_rule_88 = Set[ 1 ]
    TOKENS_FOLLOWING_type_spec_IN_start_rule_102 = Set[ 1 ]
    TOKENS_FOLLOWING_type_body_IN_start_rule_116 = Set[ 1 ]
    TOKENS_FOLLOWING_trigger_IN_start_rule_130 = Set[ 1 ]
    TOKENS_FOLLOWING_procedure_IN_start_rule_144 = Set[ 1 ]
    TOKENS_FOLLOWING_function_IN_start_rule_158 = Set[ 1 ]
    TOKENS_FOLLOWING_view_IN_start_rule_172 = Set[ 1 ]
    TOKENS_FOLLOWING_keyPACKAGE_IN_package_spec_190 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_package_spec_192 = Set[ 13, 14 ]
    TOKENS_FOLLOWING_set_IN_package_spec_194 = Set[ 1 ]
    TOKENS_FOLLOWING_keyPACKAGE_IN_package_body_218 = Set[ 5 ]
    TOKENS_FOLLOWING_keyBODY_IN_package_body_222 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_package_body_226 = Set[ 13, 14 ]
    TOKENS_FOLLOWING_set_IN_package_body_228 = Set[ 1 ]
    TOKENS_FOLLOWING_keyTYPE_IN_type_spec_251 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_type_spec_253 = Set[ 13, 14 ]
    TOKENS_FOLLOWING_set_IN_type_spec_255 = Set[ 1 ]
    TOKENS_FOLLOWING_keyTYPE_IN_type_body_278 = Set[ 5 ]
    TOKENS_FOLLOWING_keyBODY_IN_type_body_282 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_type_body_286 = Set[ 13, 14 ]
    TOKENS_FOLLOWING_set_IN_type_body_288 = Set[ 1 ]
    TOKENS_FOLLOWING_keyTRIGGER_IN_trigger_310 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_trigger_312 = Set[ 1 ]
    TOKENS_FOLLOWING_keyPROCEDURE_IN_procedure_326 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_procedure_328 = Set[ 1 ]
    TOKENS_FOLLOWING_keyFUNCTION_IN_function_342 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_function_344 = Set[ 1 ]
    TOKENS_FOLLOWING_keyVIEW_IN_view_358 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_object_name_IN_view_360 = Set[ 1 ]
    TOKENS_FOLLOWING_schema_name_IN_object_name_376 = Set[ 4 ]
    TOKENS_FOLLOWING_DOT_IN_object_name_380 = Set[ 5, 6 ]
    TOKENS_FOLLOWING_identifier_IN_object_name_387 = Set[ 1 ]
    TOKENS_FOLLOWING_identifier_IN_schema_name_400 = Set[ 1 ]
    TOKENS_FOLLOWING_set_IN_identifier_0 = Set[ 1 ]
    TOKENS_FOLLOWING_ID_IN_keyBODY_456 = Set[ 1 ]
    TOKENS_FOLLOWING_T__15_IN_keyFUNCTION_484 = Set[ 1 ]
    TOKENS_FOLLOWING_T__16_IN_keyPACKAGE_513 = Set[ 1 ]
    TOKENS_FOLLOWING_T__17_IN_keyPROCEDURE_540 = Set[ 1 ]
    TOKENS_FOLLOWING_T__18_IN_keyTYPE_572 = Set[ 1 ]
    TOKENS_FOLLOWING_T__19_IN_keyTRIGGER_602 = Set[ 1 ]
    TOKENS_FOLLOWING_T__20_IN_keyVIEW_635 = Set[ 1 ]
    TOKENS_FOLLOWING_ID_IN_keyREPLACE_667 = Set[ 1 ]

  end # class Parser < ANTLR3::Parser

  at_exit { Parser.main( ARGV ) } if __FILE__ == $0
end

