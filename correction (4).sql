--1
alter system set audit_trail=db scope=spfile; 
shutdown 
startup 
show parameter audit_trail 

--2
audit select on user1_sp.test1 by access whenever successful ; 
audit select on user1_sp.test1 by session whenever not successful ; 
audit delete on user1_sp.test2 by session; 

--3
create tablespace tbl_sp 
datafile 'fd01tbl_app.dbf' size 10m autoextend on next 2m , 'fd02tbl_app.dbf' size 10m; 

--4
create user user1_sp identified by pwd
default tablespace tbl_sp 
quota 1m on tbl_sp ; 
create user user2_sp identified by pwd
default tablespace tbl_sp 
quota 1m on tbl_sp ; 
grant create session to user1_sp , user2_sp with admin option; 
grant imp_full_database , exp_full_database to user1_sp , user2_sp ; 
grant create table to user1_sp , user2_sp; 

--5
host
expdp user1_sp/pwd directory=oracle content=all schemas=user1_sp dumpfile=export_user1.dump

--6
impdp user2_sp/pwd directory=oracle tables=emp dumpfile=export_user1.dump remap_schema= user1_sp:user2_sp content=metadata_only

--7
create or replace function fn_verif (nom varchar2 , new_pwd varchar2 , old_pwd varchar2 ) 
return boolean 
is
x number :=0; 
begin
for i in 1.. length(new_pwd) loop
if substr(new_pwd,i,1) between 'A' and 'Z' then
x:=x+1; 
end if ; 
end loop; 
if x=0 then 
raise_application_error(-20484, 'mot de passe invalide'); 
end if ; 
return true ; 
end ; 
/ 

create profile profil_sp limit
password_life_time 30  
password_verify_function fn_verif; 

--8
alter user user1_sp 
profile profil_sp ; 
alter user user2_sp 
profile profil_sp ; 

--9
create or replace function fn_nb_files ( nom dba_data_files.tablespace_name%type) return number
is
x number ; 
begin
select count(*) into x 
from dba_data_files
where tablespace_name=nom; 
return x ; 
end ; 
/

--10
create or replace procedure proc_audit( nom dba_audit_object.username%type)
is 
begin
for i in ( select action_name , obj_name
from dba_audit_object where username=nom) loop
dbms_output.put_line(i.action_name||' '||i.obj_name); 
end loop; 
end ; 
/








