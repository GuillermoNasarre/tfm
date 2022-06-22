-- staging

drop table if exists stg.flights;

drop table if exists stg.aircrafts;

drop table if exists stg.aircraft_types;

drop table if exists stg.airlines;

drop table if exists stg.airports;

drop table if exists stg.countries;

drop table if exists stg.calendar;

drop table if exists stg.manufacturers;

drop table if exists stg.jobs;


-- reporting

drop table if exists rtg.fact_flights;

drop table if exists rtg.dim_aircraft cascade;

drop table if exists rtg.dim_aircraft_type cascade;

drop table if exists rtg.dim_airline cascade;

drop table if exists rtg.dim_airport cascade;

drop table if exists rtg.dim_country cascade;

drop table if exists rtg.dim_manufacturer cascade;

drop table if exists rtg.dim_calendar cascade;

drop table if exists rtg.dim_audit cascade;