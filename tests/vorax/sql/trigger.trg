create or replace trigger trg_logon_db
after logon on database
begin
    insert into logon_tbl (who, when) values (user, sysdate);
end;
/
