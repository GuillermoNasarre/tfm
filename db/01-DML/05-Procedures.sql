CREATE OR REPLACE PROCEDURE stg.load_dim_calendar()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

	insert into rtg.dim_calendar (id, "year", "month", "day", year_week, week_day, full_date, date_name, month_name, week_day_name, is_holiday, holiday)
    select distinct on (btrim(c."key"))
    	stg.try_cast(btrim(c."key"), 0),
        btrim(c."year"),
        btrim(c."month"),
        btrim(c."day"),
        stg.try_cast(c.year_week, 0),
        stg.try_cast(c.week_day, 0),
        cast(c.full_date as date),
        btrim(c.date_name),
        btrim(c.month_name),
        btrim(c.week_day_name),
        case when c.is_holiday = '1' then true else false end,
        btrim(c.holiday)
    from stg.calendar c
    where "key" is not null;

    insert into bkp.calendar
    select *
    from stg.calendar;

    truncate table stg.calendar;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.load_dim_audit()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	
	    
    insert into rtg.dim_audit (job_id, started_at, ended_at, duration, records_extracted, records_loaded)
    select 
        j.job_id, 
        j.started_at, 
        j.ended_at, 
        j.duration, 
        j.records_extracted, 
        j.records_loaded
    from stg.jobs j;

    insert into bkp.jobs
    select *
    from stg.jobs;

    truncate table stg.jobs;

END $procedure$
;


CREATE OR REPLACE PROCEDURE stg.load_fact_flights()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	
	    
	drop table if exists temp_flights;
	create temporary table temp_flights as
	select distinct
    	btrim(lower(icao24)) icao24,
        btrim(upper(departure_airport)) departure_airport,
        btrim(upper(arrival_airport)) arrival_airport,
        cast (to_char(first_seen, 'YYYYMMDD') as int) first_seen_on, 
        cast (first_seen as time) first_seen_at, 
        cast (to_char(last_seen, 'YYYYMMDD') as int) last_seen_on, 
        cast (last_seen as time) last_seen_at,
        duration,
        distance,
        consumption,
        emissions,
        retention_period_end,
        btrim(upper(job_id)) job_id
    from stg.flights
    where icao24 is not null;

	insert into rtg.fact_flights (aircraft_id, departure_airport_id, arrival_airport_id, first_seen_on_id, first_seen_at, last_seen_on_id, last_seen_at, duration, distance, consumption, emissions, retention_period_end, audit_id)
    select
    	coalesce(ac.id, 0),
        coalesce(de.id, 0),
        coalesce(ar.id, 0),
        coalesce(cf.id, 0),
        f.first_seen_at,
        coalesce(cl.id, 0),
        f.last_seen_at,
        f.duration,
        f.distance,
        f.consumption,
        f.emissions,
        f.retention_period_end,
        coalesce(au.id, 0)
    from temp_flights f
   	left join rtg.dim_aircraft ac
   		on ac.icao24 = f.icao24
   	left join rtg.dim_airport de
   		on de.icao = f.departure_airport
	left join rtg.dim_airport ar
   		on ar.icao = f.arrival_airport
   	left join rtg.dim_calendar cf
		on cf.id = f.first_seen_on
	left join rtg.dim_calendar cl
		on cl.id = f.last_seen_on
    left join rtg.dim_audit au
        on au.job_id = f.job_id;
       
    insert into bkp.flights
    select *
    from stg.flights;

    truncate table stg.flights;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_aircraft()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	
	    
	drop table if exists temp_aircrafts;
	create temporary table temp_aircrafts as
	select distinct on (registration)
    	btrim(upper(registration)) registration, 
    	btrim(lower(icao24)) icao24,
        btrim(model) model,
        btrim(upper(icao_aircraft_type)) aircraft_type_icao,
        btrim(upper(operator_icao)) operator_icao,
        btrim("owner") "owner",
        btrim(upper(manufacturer_icao)) manufacturer_icao,
        effective_date,
        btrim(upper(job_id)) job_id
    from stg.aircrafts
    where registration is not null;
   
   drop table if exists temp_dim_aircraft;
   create temporary table temp_dim_aircraft as
   select registration 
   from rtg.dim_aircraft
   where is_current is true;
   
   drop table if exists temp_dim_aircraft_type;
   create temporary table temp_dim_aircraft_type as
   select distinct on (icao) id, icao 
   from rtg.dim_aircraft_type 
   where is_current is true;
  
   drop table if exists temp_dim_airline;
   create temporary table temp_dim_airline as
   select distinct on (icao) id, icao
   from rtg.dim_airline
   where is_current is true;
  
   drop table if exists temp_dim_manufacturer;
   create temporary table temp_dim_manufacturer as
   select distinct on (icao) id, icao
   from rtg.dim_manufacturer
   where is_current is true;
  
	insert into rtg.dim_aircraft (registration, icao24, model, aircraft_type_id, airline_id, "owner", manufacturer_id, effective_date, audit_id)
    select
    	a.registration, 
    	a.icao24,
        a.model,
        coalesce(dat.id, 0),
        coalesce(dal.id, 0),
        a."owner",
        dm.id,
        a.effective_date,
        coalesce(dau.id, 0)
    from temp_aircrafts a
    left join temp_dim_aircraft da
        on a.registration = da.registration
    left join temp_dim_aircraft_type dat
        on a.aircraft_type_icao = dat.icao
    left join temp_dim_airline dal
        on a.operator_icao = dal.icao
    left join temp_dim_manufacturer dm
        on a.manufacturer_icao = dm.icao
    left join rtg.dim_audit dau
        on a.job_id = dau.job_id
    where da.registration is null;
   
    update rtg.dim_aircraft
    set end_date = current_date,
        is_current = false
    where registration not in (select distinct registration from temp_aircrafts)
        and id > 0;

    insert into bkp.aircrafts
    select *
    from stg.aircrafts;

    truncate table stg.aircrafts;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_aircraft_type()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

	insert into rtg.dim_aircraft_type ("description", icao, engine_count, engine_type, effective_date, audit_id)
    select distinct on (btrim(upper(at2.description)))
        btrim(at2.aircraft_description),
        btrim(upper(at2.description)), 
        stg.try_cast(btrim(at2.engine_count), 0),
        btrim(at2.engine_type),
        at2.effective_date,
        coalesce(dau.id, 0)
    from stg.aircraft_types at2
    left join (select icao from rtg.dim_aircraft_type where is_current is true) dat2
        on btrim(upper(at2.description)) = dat2.icao
    left join rtg.dim_audit dau
        on btrim(upper(at2.job_id)) = dau.job_id
    where at2.description is not null and dat2.icao is null;
   
    update rtg.dim_aircraft_type
    set end_date = current_date,
        is_current = false
    where icao not in (select distinct btrim(upper(description)) from stg.aircraft_types)
        and id > 0;

    insert into bkp.aircraft_types
    select *
    from stg.aircraft_types;

    truncate table stg.aircraft_types;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_airline()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

	insert into rtg.dim_airline ("description", alias, iata, icao, effective_date, audit_id)
    select distinct on (btrim(a."name"))
    	btrim(a."name"), 
    	btrim(a.alias),
        btrim(upper(a.iata)),
        btrim(upper(a.icao)),
        a.effective_date,
        coalesce(dau.id, 0)
    from stg.airlines a
    left join (select "description" from rtg.dim_airport where is_current is true) da
        on btrim(upper(a."name")) = upper(da."description")
    left join rtg.dim_audit dau
        on btrim(upper(a.job_id)) = dau.job_id
    where a."name" is not null and upper(da."description") is null;
   
    update rtg.dim_airline
    set end_date = current_date,
        is_current = false
    where icao not in (select distinct btrim(upper(icao)) from stg.airlines)
        and id > 0;

    insert into bkp.airlines
    select *
    from stg.airlines;

    truncate table stg.airlines;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_airport()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

	insert into rtg.dim_airport ("description", iata, icao, country_id, city, latitude, longitude, altitude, time_zone, time_zone_olson, daylight_saving_time, effective_date, audit_id)
    select distinct on (btrim(upper(a.iata)))
    	btrim(a."name"), 
        btrim(upper(a.iata)),
        btrim(upper(a.icao)),
        coalesce(c.id, 0),
        btrim(a.city),
        stg.try_cast(btrim(a.latitude), 0.0),
        stg.try_cast(btrim(a.longitude), 0.0),
        stg.try_cast(btrim(a.altitude), 0),
        stg.try_cast(btrim(a.timezone), 0),
        btrim(a.tz),
        btrim(regexp_replace(upper(a.dst), '[A-Z]', '')),
        a.effective_date,
        coalesce(dau.id, 0)
    from stg.airports a
    left join (select iata from rtg.dim_airport where is_current is true) da
        on btrim(upper(a.iata)) = da.iata
    left join rtg.dim_country c
        on btrim(lower(a.country)) = lower(c.description)
    left join rtg.dim_audit dau
        on btrim(upper(a.job_id)) = dau.job_id
    where a.iata is not null and da.iata is null;
   
    update rtg.dim_airport
    set end_date = current_date,
        is_current = false
    where iata not in (select distinct btrim(upper(iata)) from stg.airports)
        and id > 0;

    insert into bkp.airports
    select *
    from stg.airports;

    truncate table stg.airports;
   
END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_country()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

    insert into rtg.dim_country ("description", official_description, iso2, iso3, region, subregion, effective_date, audit_id)
    select distinct on (btrim(upper(c.cca2)))
    	btrim(cast(cast(c."name" as jsonb) -> 'common' as text), '"'),
		btrim(cast(cast(c."name" as jsonb) -> 'official' as text), '"'),
		btrim(upper(c.cca2)), 
		btrim(upper(c.cca3)),
		btrim(c.region),
		btrim(c.subregion),
        effective_date,
        coalesce(dau.id, 0)
	from stg.countries c 
    left join (select iso2 from rtg.dim_country where is_current is true) dc
    	on btrim(upper(c.cca2)) = dc.iso2
    left join rtg.dim_audit dau
        on btrim(upper(c.job_id)) = dau.job_id
    where c.cca2 is not null and dc.iso2 is null;
   
    update rtg.dim_country
    set end_date = current_date,
        is_current = false
    where iso2 not in (select distinct btrim(upper(cca2)) from stg.countries)
        and id > 0;

    insert into bkp.countries
    select *
    from stg.countries;

    truncate table stg.countries;

END $procedure$
;

CREATE OR REPLACE PROCEDURE stg.update_dim_manufacturer()
 LANGUAGE plpgsql
AS $procedure$
    BEGIN	

	insert into rtg.dim_manufacturer ("description", icao, effective_date, audit_id)
    select distinct on (btrim(upper(m.code)))
        btrim(m."name"),
        btrim(upper(m.code)),
        m.effective_date,
        coalesce(dau.id, 0)
    from stg.manufacturers m
    left join (select icao from rtg.dim_manufacturer where is_current is true) dm
        on btrim(upper(m.code)) = dm.icao
    left join rtg.dim_audit dau
        on btrim(upper(m.job_id)) = dau.job_id
    where m.code is not null and dm.icao is null;
   
    update rtg.dim_manufacturer
    set end_date = current_date,
        is_current = false
    where icao not in (select distinct btrim(upper(code)) from stg.manufacturers)
        and id > 0;

    insert into bkp.manufacturers
    select *
    from stg.manufacturers;

    truncate table stg.manufacturers;
   
END $procedure$
;
