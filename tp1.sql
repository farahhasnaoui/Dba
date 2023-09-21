conn sys as sysdba
--1. Donner la liste des vues du dictionnaire de données d'Oracle triée par nom.
select table_name from dictionary 
order by table_name ;
--2 Donner la liste des utilisateurs créés sur le serveur. Afficher leur nom et la date de leur création.
select username, created 
from dba_users ; 
--3 Donner la liste des utilisateurs connectés sur votre instance courante.
select username
from v$session 
where type='USER'; 
--4 Déterminer la taille totale de la SGA.
select sum(value) 
from v$sga; 
--Connectez-vous avec le compte HR
conn hr/hr
--5 Affichez la liste de ses objets, leur type, la date de création et la date de dernière modification.
select object_name , object_type , created, last_ddl_time
from user_objects; 
--6 Afficher les noms des tables sur lesquelles il a des droits.
select table_name
from all_tables ; 
--7 Ecrire une procédure stockée qui permet d’afficher les noms de ses tables propriétaires.
create or replace procedure proc_tables 
is 
begin
for i in (select table_name from all_tables ) loop
dbms_output.put_line(i.table_name);
end loop; 
end ; 
/ 
--Connectez-vous avec le compte Administrateur
--activer les options d'affichage
set serveroutput on 
-- appel
execute proc_tables 
--ou
begin
proc_tables; 
end ; 
/
conn sys as sysdba
--8 Afficher le nombre total des tables créés dans le serveur.
select count(*)
from dba_tables ; 
--ou
select count(*)
from all_tables;  
--9 Afficher le nombre total de table créés par l’utilisateur HR.
select count(*)
from dba_tables
where owner='HR'; 
--10 Ecrire une fonction stockée qui prend en paramètre un utilisateur et retourne le nombre de ses objets.
create or replace function fn_nb_obj ( nom in dba_objects.owner%type ) return number 
is 
nb number ; 
 begin
select count(*) into nb
from dba_objects
where owner= nom ; 
return nb; 
end ; 
/ 
set serveroutput on 
--appel
declare 
n number ; 
begin
n:= fn_nb_obj('HR');
dbms_output.put_line(n);
end ; 
/ 
--ou
select fn_nb_obj('HR') from dual ; 

--11 Créer une procédure stockée qui permet de lister les tables relatives à l’utilisateur donné en paramètre. Tester la procédure avec l’utilisateur HR.
create or replace procedure proc_tab (nom in dba_tables.owner%type)
is 
 begin
for i in (select table_name
from dba_tables
where owner=nom)loop
dbms_output.put_line(i.table_name); 
end loop;
end ; 
/ 
--appel
execute proc_tab('HR')















