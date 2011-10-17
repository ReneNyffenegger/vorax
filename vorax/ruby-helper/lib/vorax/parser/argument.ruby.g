lexer grammar Argument;

options {
  language=Ruby;
  filter=true;
}

@all::header {
	module Vorax 
}

@all::footer {
	end
}

@members /*embbed*/ {

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

} /*embbed*/ 

@init /*embbed*/{
  @pmodules = []
  @open = false
  @stack = []
  @parent = -1
} /*embbed*/

QUOTED_STRING
  : ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\''
  ;
  
SL_COMMENT
  : '--' ~('\n'|'\r')* '\r'? '\n' 
  ;
  
ML_COMMENT
  : '/*' ( options {greedy=false;} : . )* '*/' 
  ;

PLSQL_MODULE
  : (tk1=ID '.' tk2=ID '.' tk3=ID WS? p=START_PROC)
  { @pmodules << {:name => $tk1.text + '.' + $tk2.text + '.' + $tk3.text, :args => [ArgItem.new($p.start + 1 .. $p.stop + 1, nil)] } ; @parent += 1 }
  | (tk1=ID '.' tk2=ID WS? p=START_PROC)
  { @pmodules << {:name => $tk1.text + '.' + $tk2.text, :args => [ArgItem.new($p.start + 1 .. ($p.stop + 1), nil)] } ; @parent += 1 }
  | (ID WS? p=START_PROC)
  { @pmodules << {:name => $ID.text, :args => [ArgItem.new($p.start + 1 .. ($p.stop + 1), nil)] } ; @parent += 1}
  ;

fragment
START_PROC
  : '(' WS?
  ;

CEXPR
  : tk=EXPR { @pmodules[@parent][:args] << ArgItem.new($tk.start .. $tk.stop, $tk.text) if @parent >= 0 }
  ;

fragment
PARAM_DELIM
  : ',' WS?
  ;

fragment
EXPR
  : '(' ( EXPR | ~(')') )* ')' 
  ; 

START_ARGUMENT
  : p=PARAM_DELIM
  { @pmodules[@parent][:args] << ArgItem.new($p.start + 1 .. ($p.stop + 1), nil) if @parent >= 0 }
  ;

END_FUNC
  : ')' { @parent -= 1 if @parent > 0 }
  ;

WS  
  : (' '|'\t'|'\n')+
  ;

fragment
ID 
    : 'A' .. 'Z' ( 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '#' )*
    | DOUBLEQUOTED_STRING
    ;

fragment
DOUBLEQUOTED_STRING
  : '"' ( ~('"') )* '"'
  ;


