
-- rtg.dim_audit

insert into rtg.dim_audit (id, job_id, started_at, ended_at, duration, records_extracted, records_loaded)
values (0, 'Unknown', '1970-01-01 00:00:00.000', '1970-01-01 00:00:00.000', 0, 0, 0);


-- rtg.dim_calendar

insert into rtg.dim_calendar (id, "year", "month", "day", year_week, week_day, full_date, date_name, month_name, week_day_name, is_holiday, holiday)
values (0, 'yyyy', 'mm', 'dd', 0, 0, '1970-01-01', 'NA', 'NA', 'NA', False, 'NA');


-- rtg.dim_country

insert into rtg.dim_country (id, "description", official_description, iso2, iso3, region, subregion, effective_date)
values (0, 'Unknown', 'NA', 'NA', 'NA', 'NA', 'NA', '1970-01-01 00:00:00.000');


-- rtg.dim_manufacturer

insert into rtg.dim_manufacturer (id, "description", icao, effective_date)
values (0, 'Unknown', 'NA', '1970-01-01 00:00:00.000');


-- rtg.dim_airline

insert into rtg.dim_airline (id, "description", alias, iata, icao, effective_date)
values (0, 'Unknown', 'NA', 'NA', 'NA', '1970-01-01 00:00:00.000');


-- rtg.dim_aircraft_type

insert into rtg.dim_aircraft_type (id, "description", icao, engine_count, engine_type, effective_date)
values (0, 'Unknown', 'NA', 0, 'NA', '1970-01-01 00:00:00.000');


-- rtg.dim_airport

insert into rtg.dim_airport (id, "description", iata, icao, country_id, city, latitude, longitude, altitude, time_zone, time_zone_olson, daylight_saving_time, effective_date)
values (0, 'Unknown', 'NA', 'NA', 0, 'NA', 0.0, 0.0, 0, 0, null, null, '1970-01-01 00:00:00.000');


-- rtg.dim_aircraft

insert into rtg.dim_aircraft (id, icao24, registration, model, aircraft_type_id, airline_id, "owner", manufacturer_id, effective_date)
values (0, 'Unknown', 'Unknown', 'NA', 0, 0, 'NA', 0, '1970-01-01 00:00:00.000');


-- lkp.fuel_consumptions

insert into lkp.fuel_consumptions (nm_start, nm_end, fuel_tonnes)
values (1,125,2.04),
(126,250,4.12),
(251,500,5.7),
(501,750,7.78),
(751,1000,10.67),
(1001,1500,15.38),
(1501,2000,24.76),
(2001,2500,33.29),
(2501,3000,41.39),
(3001,3500,50.13),
(3501,4000,58.54),
(4001,4500,75.92),
(4501,5000,86.48),
(5001,5500,99.58),
(5501,6000,112.95),
(6001,6500,120.93),
(6501,7000,137.3),
(7001,7500,151.22),
(7501,8000,120.82),
(8001,8500,106.09);