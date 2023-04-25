connect sys as sysdba
--1
Select * From DICT order by table_name;

--2
select username, created from dba_users;

--3
Select username from v$session where type='USER';

--4
Select SUM(value) From v$SGA;



connect sys as sysdba
alter user hr identified by hr account unlock;

connect hr/hr 
--5
select object_type, created, last_ddl_time From USER_OBJECTS;

--6
Select table_name FROM ALL_TABLES;

--7
CREATE OR REPLACE PROCEDURE Proc_list_tabs
IS
BEGIN
For i in (Select table_name A, owner B FROM all_TABLES) loop
dbms_output.put_line(rpad(i.A,30) || ' - '  ||rpad(i.B,30));
end loop;
END;
/


CREATE OR REPLACE PROCEDURE Proc_list_tabs
IS
cursor c is Select table_name A, owner B FROM all_TABLES;
BEGIN
For i in c loop
dbms_output.put_line(c%rowcount || ' - ' || 
                     rpad(i.A,30) || ' - '  ||
                     rpad(i.B,30));
end loop;
END;
/
--APPEL
set serveroutput on
execute Proc_list_tabs

BEGIN
Proc_list_tabs;
END;
/
conn sys as sysdba
--8
select count(*) from dba_tables; --ou all_tables

--9
select count(*) from all_tables where owner='HR';
OU
Select count(*) from dba_tables where owner='HR';

--10
create or replace function fn_nbrObjet (utilisateur varchar)
return number 
is
a number;
BEGIN
select count(*) into a from dba_objects where 
owner = UPPER(utilisateur);
RETURN a;
END;
/

--11
CREATE OR REPLACE PROCEDURE PS_GET_TABLES_OF_USER 
(utilisateur varchar)
IS
BEGIN
for i in (select table_name from dba_tables where owner=utilisateur) LOOP
dbms_output.put_line(i.table_name);
END LOOP;
END;
/

execute PS_GET_TABLES_OF_USER('&a')
OU
DECLARE
a varchar(30) := '&a';
BEGIN
PS_GET_TABLES_OF_USER(a);
END;
/

























