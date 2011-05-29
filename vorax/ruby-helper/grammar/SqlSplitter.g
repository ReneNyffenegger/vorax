//!/usr/bin/antlr4ruby -verbose -fo vorax/ruby-helper/lib/vorax/parser/ %

lexer grammar SqlSplitter;

options {
  language=Ruby;
  filter=true;
}

QUOTED_STRING
  : ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\''
  ;
  
SL_COMMENT
  : '--' ~('\n'|'\r')* '\r'? '\n' 
  ;
  
ML_COMMENT
  : '/*' ( options {greedy=false;} : . )* '*/' 
  ;

SQL_SEPARATOR
  : ';' | (CR  SPACE* '/' SPACE* (CR | EOF))
  ;

fragment
CR
  : '\n'+
  ;

fragment
SPACE
  : (' '|'\t')+
  ;

fragment
WS  
  : (' '|'\t'|'\n')+
  ;
