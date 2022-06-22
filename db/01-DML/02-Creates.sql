-- staging

create schema stg;

create table stg.airports (
    airport_id text,
    "name" text,
    city text,
    country text,
    iata text,
    icao text,
    latitude text,
    longitude text,
    altitude text,
    timezone text,
    dst text,
    tz text,
    "type" text,
    "source" text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.airlines (
    airline_id text,
    "name" text,
    alias text,
    iata text,
    icao text,
    callsign text,
    country text,
    active text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.aircrafts (
    icao24 text,
    registration text,
    manufacturer_icao text,
    manufacturer_name text,
    model text,
    type_code text,
    serial_number text,
    line_number text,
    icao_aircraft_type text,
    operator text,
    operator_callsign text,
    operator_icao text,
    operator_iata text,
    "owner" text,
    test_reg text,
    registered text,
    reg_until text,
    "status" text,
    built text,
    first_flight_date text,
    seat_configuration text,
    engines text,
    modes text,
    adsb text,
    acars text,
    notes text,
    category_description text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.aircraft_types (
    aircraft_description text,
    "description" text,
    designator text,
    engine_count text,
    engine_type text,
    manufacturer_code text,
    model_full_name text,
    wtc text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.manufacturers (
    code text,
    "name" text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.countries (
    "name" text,
    cca2 text,
    cca3 text,
    region text,
    subregion text,
    effective_date date not null default current_date,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.calendar (
    "key" text,
    "year" text,
    "month" text,
    "day" text,
    year_week text,
    week_day text,
    full_date text,
    date_name text,
    month_name text,
    week_day_name text,
    is_holiday text,
    holiday text,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.flights (
    icao24 text not null,
    first_seen timestamp,
    last_seen timestamp,
    duration int,
    departure_airport text not null,
    arrival_airport text not null,
    distance smallint,
    consumption numeric,
    emissions numeric,
    retention_period_end date not null,
    job_id text not null default 0,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table stg.jobs(
    job_id text not null,
    started_at timestamp not null,
    ended_at timestamp not null,
    duration int not null,
    records_extracted int not null,
    records_loaded int not null,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);


-- reporting

create schema rtg;

create table rtg.dim_airport (
    id serial,
    "description" text,
    iata text,
    icao text,
    country_id int,
    city text,
    latitude numeric,
    longitude numeric,
    altitude smallint,
    time_zone smallint,
    time_zone_olson text,
    daylight_saving_time char(1),
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_airline (
    id serial,
    "description" text,
    alias text,
    iata text,
    icao text,
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_aircraft (
    id serial,
    icao24 text,
    registration text,
    model text,
    aircraft_type_id int not null default 0,
    airline_id int not null default 0,
    "owner" text,
    manufacturer_id int not null default 0,
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_aircraft_type (
    id serial,
    "description" text,
    icao text,
    engine_count smallint,
    engine_type text,
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_manufacturer (
    id serial,
    "description" text,
    icao text,
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_country (
    id serial,
    "description" text,
    official_description text,
    iso2 char(2),
    iso3 char(3),
    region text,
    subregion text,
    is_current bool not null default true,
    effective_date date not null default current_date,
    end_date date not null default '2999-12-31',
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_calendar (
    id int,
    "year" char(4),
    "month" char(2),
    "day" char(2),
    year_week smallint,
    week_day smallint,
    full_date date,
    date_name text,
    month_name text,
    week_day_name text,
    is_holiday bool,
    holiday text,
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.fact_flights (
    id serial,
    aircraft_id int not null default 0,
    departure_airport_id int not null default 0,
    arrival_airport_id int not null default 0,
    first_seen_on_id int not null default 0,
    first_seen_at time,
    last_seen_on_id int not null default 0,
    last_seen_at time,
    duration smallint,
    distance smallint,
    consumption numeric,
    emissions numeric,
    retention_period_end date not null,
    audit_id int not null default 0,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table rtg.dim_audit(
    id serial,
    job_id text not null,
    started_at timestamp not null,
    ended_at timestamp not null,
    duration int not null,
    records_extracted int not null,
    records_loaded int not null,
    modified_by text,
    modified_at timestamp,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);



-- backup

create schema bkp;

create table bkp.airports (
    airport_id text,
    "name" text,
    city text,
    country text,
    iata text,
    icao text,
    latitude text,
    longitude text,
    altitude text,
    timezone text,
    dst text,
    tz text,
    "type" text,
    "source" text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.airlines (
    airline_id text,
    "name" text,
    alias text,
    iata text,
    icao text,
    callsign text,
    country text,
    active text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.aircrafts (
    icao24 text,
    registration text,
    manufacturer_icao text,
    manufacturer_name text,
    model text,
    type_code text,
    serial_number text,
    line_number text,
    icao_aircraft_type text,
    operator text,
    operator_callsign text,
    operator_icao text,
    operator_iata text,
    "owner" text,
    test_reg text,
    registered text,
    reg_until text,
    "status" text,
    built text,
    first_flight_date text,
    seat_configuration text,
    engines text,
    modes text,
    adsb text,
    acars text,
    notes text,
    category_description text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.aircraft_types (
    aircraft_description text,
    "description" text,
    designator text,
    engine_count text,
    engine_type text,
    manufacturer_code text,
    model_full_name text,
    wtc text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.manufacturers (
    code text,
    "name" text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.countries (
    "name" text,
    cca2 text,
    cca3 text,
    region text,
    subregion text,
    effective_date text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.calendar (
    "key" text,
    "year" text,
    "month" text,
    "day" text,
    year_week text,
    week_day text,
    full_date text,
    date_name text,
    month_name text,
    week_day_name text,
    is_holiday text,
    holiday text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.flights (
    icao24 text,
    first_seen text,
    last_seen text,
    duration text,
    departure_airport text,
    arrival_airport text,
    distance text,
    consumption text,
    emissions text,
    retention_period_end text,
    job_id text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create table bkp.jobs(
    job_id text,
    started_at text,
    ended_at text,
    duration text,
    records_extracted text,
    records_loaded text,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);


-- lookup

create schema lkp;

create table lkp.fuel_consumptions(
    id serial,
    nm_start int not null,
    nm_end int not null,
    fuel_tonnes numeric not null,
    created_by text not null default current_user,
    created_at timestamp not null default current_timestamp
);

create view lkp.airport_coordinates as 
select icao, iata, latitude, longitude
from rtg.dim_airport;



-- dw_etl

create user dw_etl with password 'REPLACE_ME';


-- dw_read

create user dw_read with password 'REPLACE_ME'; 