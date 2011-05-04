-- This script creates an oracle user to be used by the VoraX unit tests.
-- It also creates the corresponding Oracle objects needed by those unit tests.
-- Please run this script under an admin user.

prompt This script creates an oracle user to be used by VoraX unit tests.
prompt The script asks for the username to be created, password etc. The default values
prompt are provided in []. If you are fine with these default values just press ENTER.
prompt 

accept user prompt 'Enter the username to be created [vorax]: ' default 'vorax'
accept pwd prompt 'Enter a password for the above user [vorax]: ' default 'vorax' hide
accept default_tbs prompt 'Enter a default tablespace for this user (must exist) [USERS]: ' default 'USERS'

set verify off
create user &user identified by &pwd default tablespace &default_tbs quota 50M on &default_tbs;
grant create session, create view, create procedure, create type, create synonym, create sequence, create table to &user;
