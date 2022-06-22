-- dw_etl

revoke all on database postgres from dw_etl;

revoke usage on schema stg from dw_etl;
revoke all on all tables in schema stg from dw_etl;
alter default privileges in schema stg revoke all on tables from dw_etl;
alter default privileges in schema stg revoke all on sequences from dw_etl;

revoke usage on schema rtg from dw_etl;
revoke all on all tables in schema rtg from dw_etl;
alter default privileges in schema rtg revoke all on tables from dw_etl;
alter default privileges in schema rtg revoke all on sequences from dw_etl;

revoke usage on schema bkp from dw_etl;
revoke all on all tables in schema bkp from dw_etl;
alter default privileges in schema bkp revoke all on tables from dw_etl;
alter default privileges in schema bkp revoke all on sequences from dw_etl;

revoke usage on schema lkp from dw_etl;
revoke all on all tables in schema lkp from dw_etl;
alter default privileges in schema lkp revoke all on tables from dw_etl;
alter default privileges in schema lkp revoke all on sequences from dw_etl;


-- dw_read

revoke all on database postgres from dw_read;

revoke all on all tables in schema rtg from dw_read;
revoke usage on schema rtg from dw_read;
alter default privileges in schema rtg revoke all on tables from dw_read;
alter default privileges in schema rtg revoke all on sequences from dw_read;