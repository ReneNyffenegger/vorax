grammar Source;

options {
	language=Ruby;
	k='*';
	backtrack=true;
	memoize=true;
	output=AST;
}

@members {
  attr_reader :object_owner, :object_type, :object_name
}

@init {
  @object_owner = ''
  @object_type = ''
  @object_name = ''
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
	:	keyPACKAGE object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'PACKAGE' }
	;
	
package_body
	:	keyPACKAGE ( keyBODY ) object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'PACKAGE BODY' }
	;

type_spec
	:	keyTYPE object_name ( 'IS' | 'AS' ) 
	{ @object_type = 'TYPE' }
	;

type_body
	:	keyTYPE ( keyBODY ) object_name ( 'IS' | 'AS' )
	{ @object_type = 'TYPE BODY' }
	;

trigger
	:	keyTRIGGER object_name
	{ @object_type = 'TRIGGER' }
	;

procedure
	:	keyPROCEDURE object_name
	{ @object_type = 'PROCEDURE' }
	;

function
	:	keyFUNCTION object_name
	{ @object_type = 'FUNCTION' }
	;

view
	:	keyVIEW object_name
	{ @object_type = 'VIEW' }
	;

object_name
	:	( schema_name { @object_owner = $schema_name.text } DOT )? 
	identifier { @object_name = $identifier.text }
	;

schema_name
	:	identifier 
	;

identifier
	:	ID
	|	DOUBLEQUOTED_STRING 
  ;

keyBODY                          : {self.input.look(1).text.upcase == ("BODY")}? ID;
keyFUNCTION                      : 'FUNCTION';
keyPACKAGE                       : 'PACKAGE';
keyPROCEDURE                     : 'PROCEDURE';
keyTYPE                          : 'TYPE'; 
keyTRIGGER                       : 'TRIGGER'; 
keyVIEW                          : 'VIEW'; 
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

