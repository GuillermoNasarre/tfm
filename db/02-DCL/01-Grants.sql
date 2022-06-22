-- dw_etl

grant connect on database postgres to dw_etl;

grant usage on schema stg to dw_etl;
grant insert, delete on all tables in schema stg to dw_etl;
grant usage, select on all sequences in schema stg to dw_etl;
grant execute on all routines in schema stg to dw_etl;
alter default privileges in schema stg grant insert, delete on tables to dw_etl; 
alter default privileges in schema stg grant usage, select on sequences to dw_etl;
alter default privileges in schema stg grant execute on routines to dw_etl; 

grant usage on schema rtg to dw_etl;
grant insert on all tables in schema rtg to dw_etl;
grant usage, select on all sequences in schema rtg to dw_etl;
alter default privileges in schema rtg grant insert on tables to dw_etl; 
alter default privileges in schema rtg grant usage, select on sequences to dw_etl; 

grant usage on schema bkp to dw_etl;
grant select on all tables in schema bkp to dw_etl;
grant usage, select on all sequences in schema bkp to dw_etl;
alter default privileges in schema bkp grant select on tables to dw_etl;
alter default privileges in schema bkp grant usage, select on sequences to dw_etl; 

grant usage on schema lkp to dw_etl;
grant select on all tables in schema lkp to dw_etl;
grant usage, select on all sequences in schema lkp to dw_etl;
alter default privileges in schema lkp grant select on tables to dw_etl;
alter default privileges in schema lkp grant usage, select on sequences to dw_etl; 

-- dw_read

grant connect on database postgres to dw_read;

grant usage on schema rtg to dw_read;
grant select on all tables in schema rtg to dw_read;
grant usage, select on all sequences in schema rtg to dw_read;
alter default privileges in schema rtg grant select on tables to dw_read;
alter default privileges in schema rtg grant usage, select on sequences to dw_read; 