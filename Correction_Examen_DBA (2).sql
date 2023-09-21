--1
create tablespace tbl_sp 
datafile 'df01.dbf' size 10m autoextend on next 2m , 'df02.dbf' size 20M;
--2
alter tablespace tbl_sp offline; 
--renoomer le fichier physiquement 
alter tablespace tbl_sp rename datafile 'df02.dbf' to 'datafile02.dbf'; 
alter tablespace tbl_sp online ; 
--3
CREATE OR REPLACE Function verif_password(p_username varchar2, 
p_password varchar2, old_password varchar2) RETURN boolean 
IS
c integer:=0;
x integer:=0;
BEGIN
if not (ascii(substr(p_password,1,1)) between ascii('A') and ascii('Z'))  then 
raise_application_error(-20001,'Le mot de passe doit commencer par majuscule');
end if;
return true;
end;
/
create profile profile_sp limit
password_reuse_max 3
password_verify_function verif_password; 
--4
create user user_sp identified by user_sp 
default tablespace tbl_sp
quota 1m on tbl_sp
profile profile_sp
password expire ; 
--5
create role role_sp; 
grant create session to role_sp ; 
grant imp_full_database , exp_full_database to role_sp; 
grant update(salary) on hr.employees to role_sp ; 

--6
grant role_sp to user_sp with admin option ; 
--7
alter system set audit_trail=os scope=spfile ; 
alter system set audit_file_dest= 'c:\oraclexe\app\oracle' scope=spfile; 
--8
audit create session by user_sp by access whenever not successful ; 
--9 
audit update on hr.employees ; 
--10
create or replace function fn_nb_files ( nom varchar2) return number 
is 
nb number ; 
begin
select count(*) into nb 
from dba_segments 
where tablespace_name = nom ; 
end ; 
/
--11
create or replace procedure proc_privs ( nom varchar2) 
is 
begin
for i in  ( select privilege 
from dba_sys_privs where grantee=nom) loop
dbms_output.put_line (i.privilege); 
end loop; 
end ; 
/ 
--12
expdp user_sp/user_spp tablespaces=tbl_sp directory=oracle content=metadata_only dumpfile=Export.dump
--13
load data infile 'data.txt'
append into table compte 
fields terminated by '|' 
(id, 
currency, 
date_v "to_date(:date_v,'DDMMYYYY')", 
montant "round(to_number(:montant),1 )")
