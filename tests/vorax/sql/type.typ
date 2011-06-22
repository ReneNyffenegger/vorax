create or replace 
type my_pkg as

  procedure test;

end;
/
create or replace
type body my_pkg as

  procedure test as
  begin
    null;
  end;

end;
/

