if !exists( "g:__XPTEMPLATE_VIM__" )
  " load only if xptemplate plugin is loaded
  finish
endif

XPTemplate priority=sub

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common

fun! s:f.getObjectName()
  return b:vorax_module.object
endfunction

fun! s:f.getObjectOwner()
  return b:vorax_module.owner
endfunction

XPT _new_package hidden
create or replace package `getObjectOwner()^.`getObjectName()^ as
  `cursor^
end;
/

create or replace package body `getObjectOwner()^.`getObjectName()^ as
  
end;
/
..XPT

XPT _new_procedure hidden
create or replace procedure `getObjectOwner()^.`getObjectName()^ as
  `cursor^
end;
/
..XPT

XPT _new_function hidden
create or replace function `getObjectOwner()^.`getObjectName()^ return `type^ as
begin
  `cursor^
end;
/
..XPT

XPT _new_type hidden
create or replace type `getObjectOwner()^.`getObjectName()^ as
  `cursor^
end;
/

create or replace type body `getObjectOwner()^.`getObjectName()^ as
  
end;
/
..XPT

XPT _new_trigger hidden
create or replace trigger `getObjectOwner()^.`getObjectName()^ 
  `fires: before|after|instead of^ `event: insert|update|delete^
  on `table|view^
  for each row
begin
  `cursor^
end;
/
..XPT
