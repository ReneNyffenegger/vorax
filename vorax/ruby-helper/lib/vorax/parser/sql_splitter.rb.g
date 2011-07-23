//!antlr4ruby -verbose -fo vorax/ruby-helper/lib/vorax/parser/ %

lexer grammar SqlSplitter;

options {
  filter=true;
  language='Ruby';
}

@init {
  @separators = []
}

@members {

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
        stmt = text[(last_pos ... pos)]
        statements << stmt unless stmt =~ /\A[\r\n\t ]*\Z/
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

}

QUOTED_STRING
  : ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\''
  ;
  
SL_COMMENT
  : '--' ~('\n'|'\r')* '\r'? ('\n' | EOF)
  ;
  
ML_COMMENT
  : '/*' ( options {greedy=false;} : . )* '*/' 
  ;

SQL_SEPARATOR
  : SQL_SEPARATOR_1 { mark_this($SQL_SEPARATOR_1) }
    | 
    SQL_SEPARATOR_2 { mark_this($SQL_SEPARATOR_2) }
  ;

fragment
SQL_SEPARATOR_1
  : ';'
  ;

fragment
SQL_SEPARATOR_2
  : CR  SPACE* '/' SPACE* (CR | EOF)
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

