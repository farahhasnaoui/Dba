--1
create tablespace tbl_esprit
datafile 'c:\fd01.dbf' size 10m autoextend on next 2m , 'c:\fd02.dbf' size 10 m ; 
--2
alter tablespace tbl_esprit
add datafile 'c:\fd03.dbf' size 15m autoextend on next 1m maxsize 40m ;
--3
create or replace procedure PR_TABLES 
is
begin
for i in ( select tablespace_name from dba_tablespaces ) loop
dbms_output.put_line(i.tablespace_name);
for j in ( select table_name from dba_tables where tablespace_name=i.tablespace_name) loop 
dbms_output.put_line(j.table_name);
end loop; 
end loop;
end ; 
/ 
--4
create or replace function fn_verif (p_user varchar2 , p_new varchar2 , p_old varchar2 ) return boolean 
is
a number :=0; 
begin
if (substr(p_new,1,1)!=substr(p_user,1,1)) then
raise_application_error ( -20877,'verfier mdp');
end if ; 
for i in 1..length(p_new) loop
 if (ascii(substr(p_new , i , 1)) >= ascii('A')) and (ascii(substr(p_new , i , 1)) <= ascii('Z')) then a:=a+1; 
end if; 
end loop; 
if ( a<length(p_new)) then 
raise_application_error ( -20877,'verfier mdp');
end if ; 
return true ;
end ; 
/ 
create profile PROFIL_USERS limit 
password_reuse_time 2
cpu_per_call 5000
password_verify_function fn_verif; 
--5
create user User1 identified by UESPRIT default tablespace tbl_esprit quota 20m on tbl_esprit profile profil_users account lock ; 
create user User2 identified by UESPRIT default tablespace tbl_esprit quota 20m on tbl_esprit profile profil_users account lock ; 
--6
create directory dict_oracle as 'C:\oraclexe\app\oracle';
--7
grant imp_full_database, exp_full_database to user1, user2 ;
grant create session to user1, user2 with admin option;
grant create procedure to user1, user2 ;
grant read , write on directory dict_oracle to user1, user2 ;
--8
expdp user1/UESPRIT dumpfile=export.dump tables=article directory=dict_oracle content=all 
--9
impdp user2/UESPRIT dumpfile=export.dump tables=article directory=dict_oracle content=metadata_only remap_schema=user1:user2
--10
alter system set audit_trail=xml scope=spfile ; 
--11
audit update table by session ; 
--12
audit create synonym by user1 by access;
--13 
create or replace function FN_SESSION ( p_user varchar2 ) return date 
is 
d date ;
begin
select timestamp into d 
from dba_audit_session
where username=p_user;
return d; 
end ;
/ 
--14
load data infile 'C:\emp.txt'
insert into table employe 
when (extract(year from date_aissance) = 1990)
fields terminated by ","
(nom_prenom , 
date_aissance "to_date(:date_aissance)",
salaire "to_number(:salaire)")









