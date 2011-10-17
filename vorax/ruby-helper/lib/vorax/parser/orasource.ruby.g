grammar Orasource;

options {
	language=Ruby;
	k='*';
	backtrack=true;
	memoize=true;
	output=AST;
}

@all::header {
	module Vorax 
}

@all::footer {
	end
}


@members {
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
}

@init {
  @object_owner = nil
  @object_type = nil
  @object_name = nil
}

start_rule
	:	'CREATE' ( 'OR' keyREPLACE )?
    (package_spec
     |
     package_body
     |
     type_spec
     |
     type_body
     |
     trigger
     |
     procedure
     |
     function
     |
     view
     )
	;

package_spec
	:	'PACKAGE' oracle_object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'PACKAGE' unless @object_type  }
	;
	
package_body
	:	'PACKAGE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'PACKAGE_BODY' unless @object_type  }
	;

type_spec
	:	'TYPE' oracle_object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'TYPE' unless @object_type  }
	;

type_body
	:	'TYPE' ( keyBODY ) oracle_object_name ( 'IS' | 'AS' )
	{ @object_type = 'TYPE_BODY' unless @object_type  }
	;

trigger
	:	'TRIGGER' oracle_object_name
	{ @object_type = 'TRIGGER' unless @object_type  }
	;

procedure
	:	'PROCEDURE' oracle_object_name
	{ @object_type = 'PROCEDURE' unless @object_type  }
	;

function
	:	'FUNCTION' oracle_object_name
	{ @object_type = 'FUNCTION' unless @object_type  }
	;

view
	:	'VIEW' oracle_object_name
	{ @object_type = 'VIEW' unless @object_type }
	;

oracle_object_name
	:	( schema_name { @object_owner = $schema_name.text unless @object_owner } DOT )? 
	identifier { @object_name = $identifier.text unless @object_name }
	;

schema_name
	:	identifier 
	;

identifier
	:	ID
	|	DOUBLEQUOTED_STRING 
  ;

keyBODY                          : {self.input.look(1).text.upcase == ("BODY")}? ID;
keyREPLACE                       : {self.input.look(1).text.upcase == ("REPLACE")}? ID;

ID /*options { testLiterals=true; }*/
    :	'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
    |	DOUBLEQUOTED_STRING
    ;

fragment
DOUBLEQUOTED_STRING
	:	'"' ( ~('"') )* '"'
	;

WS	:	(' '|'\r'|'\t'|'\n') {$channel=HIDDEN;}
	;
SL_COMMENT
	:	'--' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
	;
ML_COMMENT
	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
	;

DOT
	:	POINT
	;

fragment
POINT
	:	'.'
	;

