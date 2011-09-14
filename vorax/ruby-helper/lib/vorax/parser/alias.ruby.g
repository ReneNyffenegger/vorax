lexer grammar Alias;

options {
  language=Ruby;
  filter=true;
	backtrack=true;
	k=100;
}

@members /*embbed*/ {

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

} /*embbed*/

@init /*embbed*/{
  @aliases = []
  @last_table = nil;
  @last_owner = nil;
  @last_dblink = nil;
  @last_alias = nil;
}/*embbed*/

QUOTED_STRING
  : ( 'n' )? '\'' ( '\'\'' | ~('\'') )* '\''
  ;
  
SL_COMMENT
  : '--' ~('\n'|'\r')* '\r'? '\n'
  ;
  
ML_COMMENT
  : '/*' ( options {greedy=false;} : . )* '*/'
  ;

FROM
  : 'FROM' WS TABLE_REFERENCE (WS? ',' WS? TABLE_REFERENCE)*
  ;

INTO
  : 'INTO' WS TABLE_REFERENCE (WS? ',' WS? TABLE_REFERENCE)*
  ;

UPDATE
  : 'UPDATE' WS TABLE_REFERENCE (WS? ',' WS? TABLE_REFERENCE)*
  ;

JOIN_CLAUSE
  : 'JOIN' WS TABLE_REFERENCE WS?
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

LBR
  : '(' { @@level += 1 }
  ;

RBR
  : ')' { @@level -= 1 }
  ;

fragment
SUB_SELECT
  : '(' ( SUB_SELECT | ~(')') )* ')'
  ;

fragment
OBJ_ALIAS
  : {(KEYS.find { |key| next_word() == key }).nil? }? ID
  /*embbed*/{
    @last_alias = $ID.text
  }/*embbed*/
  ;

fragment
PLAIN_TABLE_REF
  : (owner=ID '.')? table=ID ('@' dblink=ID)? {
    @last_table = $table ? $table.text : ''
    @last_owner = $owner ? $owner.text : ''
    @last_dblink = $dblink ? $dblink.text : ''
  }
  ;

fragment
TABLE_REFERENCE_WITH_ALIAS
  : PLAIN_TABLE_REF WS OBJ_ALIAS
  ;

fragment
TABLE_REFERENCE
  : (ss=SUB_SELECT WS? OBJ_ALIAS?)
    {
      if @last_alias
        add_alias(@last_alias, $ss.text, nil, nil, true)
      else
        add_alias(nil, $ss.text, nil, nil, true)
      end
      text = $ss.text
      @aliases += Alias::Lexer.gather_for(text,0)
      @input.consume
    }
    |
    (TABLE_REFERENCE_WITH_ALIAS WS?)
    {
      add_alias(@last_alias, @last_table, @last_owner, @last_dblink)
    }
    |
    (PLAIN_TABLE_REF WS?)
    {
      add_alias(nil, @last_table, @last_owner, @last_dblink)
    }
  ;
