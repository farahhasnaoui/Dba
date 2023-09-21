create temporary tablespace tb_control 
tempfile 'f111.dbf' size 5m , 'f211.dbf' size 5m ; 

alter database default temporary tablespace tb_control; 

create profile profil_exam limit
failed_login_attempts 3 
password_lock_time 1 
password_reuse_time 2
cpu_per_call 60 ; 

create or replace function FN_VERIF (user_name varchar, password varchar, old_password varchar) return boolean
is 
x number ; 
begin
for j in 1..length(password) loop
if substr(password,j,1) not between '0'and '9'
then x:=x+1;
end if;
end loop;

if x=0 then raise_application_error(-20001,'Le mot de passe doit contenir au moins un chiffre ');
end if;

if Ascii(substr(password,length(password),1)) not between AScii('A') and Ascii('Z') then
raise_application_error(-20001,'Le mot de passe doit se terminer par une lettre alphabetique');
end if ; 
return true ; 
end ; 
/ 

alter profile profil_exam limit
password_verify_function FN_VERIF  ; 

create user user_ctl identified by test
default tablespace users 
quota 5m on users
temporary tablespace tb_control profile profil_exam
account lock ; 

create or replace function FN_NB_USERS return number 
is 
nb number ; 
begin
select count(*) into nb 
from dba_users 
where account_status='EXPIRED & LOCKED'; 
return nb ;
end ; 
/

create role role_ctl ; 
grant create session to role_ctl with admin option; 
grant create procedure to role_ctl with admin option; 
grant select on hr.job_history to role_ctl with grant option ; 

grant role_ctl to user_ctl; 

create or replace procedure Liste_PRIVS( role varchar)
is 
begin
for i in ( select granted_role from role_role_privs where role=role) loop
dbms_output.put_line(i.granted_role) ; 
end loop; 
end ; 
/

alter system set audit_trail=os scope=spfile;

audit create trigger by user_ctl whenever successful ; 
audit create session by access ; 
audit insert on hr.regions by session ; 

create or replace procedure AUDIT_OPTS ( tablee varchar) 
is 
a varchar(30); 
b varchar(30); 
c varchar(30); 
begin
select ins , upd , sel into a , b , c 
from dba_obj_audit_opts 
where object_name=tablee; 
dbms_output.put_line(a||' '||b||' '||c) ; 
end ; 
/ 






