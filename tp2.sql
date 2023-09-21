/*
-emplacement par defaut : C:\oraclexe\app\oracle\product\10.2.0\server\database
conn sys as sysdba
--1
create tablespace tbl01 
datafile 
'fd01tbl01.dbf' size 6m autoextend off, 'c:\fd02tbl01.dbf' size 4m ; 
--2
alter database default tablespace tbl01;
--test
create user sae1 identified by sae1 ;
select default_tablespace from dba_users where username='SAE1';
--3
create tablespace tbl02
datafile 'fd01tbl02.dbf' size 10m, 
'fd02tbl02.dbf' size 10m , 
'fd0xbl02.dbf' size 5m ; 
--4
alter tablespace tbl01
add datafile 'fd02tbl01.dbf' size 20m ; 

--5
C:\oraclexe\app\oracle\product\10.2.0\server\database
--fermer les fichiers 
alter tablespace tbl02 offline ;
--renommer le fichier physiquement 
--renommer le fichier logiquement
alter tablespace tbl02
rename datafile 'fd0xbl02.dbf' to 'fd03bl02.dbf'; 
--ouvrir les fichiers 
alter tablespace tbl02 online ;
--6
select tablespace_name
from dba_tablespaces ; 
--7
set serveroutput on 
begin
for i in (select tablespace_name , count(file_name) nb 
from dba_data_files 
group by tablespace_name ) loop
dbms_output.put_line(i.tablespace_name||' '||i.nb); 
end loop; 
end ; 
/ 
--8
alter tablespace tbl01
add datafile 'fd04tlb01.dbf' size 2m 
autoextend on 
next 1m 
maxsize 4m ; 
--9
create temporary tablespace montemp4 
tempfile 'ftempsae1.dbf' size 5m ; 
alter database default temporary tablespace montemp4; 
--10
create or replace function fn_nb_temp 
return number 
is
nb number ;
begin
select count(*) into nb 
from dba_tablespaces 
where contents='TEMPORARY'; 
return nb ; 
end ;
/
--appel
select fn_nb_temp from dual ; 
--11
create user sae11 identified by sae11; 
select default_tablespace, temporary_tablespace from dba_users 
where username='SAE11'; 
--12
alter database default tablespace users; 
drop tablespace tbl01 including contents and datafiles ;

select default_tablespace, temporary_tablespace from dba_users 
where username='SAE11'; 
*/
--13
create or replace procedure proc_details_tab 
is
total number ; 
occupee number ; 
begin
for i in ( select tablespace_name nom from dba_tablespaces 
where contents='PERMANENT') loop

select sum(bytes) into total
from dba_data_files 
where tablespace_name=i.nom; 

select sum(bytes) into occupee
from dba_segments 
where tablespace_name=i.nom; 

dbms_output.put_line(i.nom||' '||total||' '||occupee); 
end loop; 
end ; 
/ 
--13
-- donner le privilege à l'utilisateur pour pouvoir se connecter et creer des tables
grant create session , create table to sae11; 
--donner à l'utilisateur un quota( espace de stockage limite pour un utilisateur ) sur le tablespace users
alter user sae11 quota 5M on users ; 

conn sae11/sae11
--creer la table etudiant
CREATE TABLE Etudiants
(num_etud number(10) primary key,
nom_etud varchar2(30),
moyenne_etud number(4,2)
) ;
--alimenter la table etudiant
BEGIN
for i in 1 .. 10000 LOOP
insert into Etudiants (num_etud, nom_etud,
moyenne_etud )
values (i , 'Etudiant'||i ,10) ;
END LOOP;
END ;
/
--14
execute ps_details_tab
ancienne: USERS 104857600 17170432
nouvelle: USERS 104857600 17694720






