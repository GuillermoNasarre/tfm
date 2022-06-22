-- reporting

alter table rtg.dim_audit add constraint audit_pkey primary key (id);

alter table rtg.dim_calendar add constraint dim_calendar_pkey primary key (id);
alter table rtg.dim_calendar add constraint dim_calendar_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_country add constraint dim_country_pkey primary key (id);
alter table rtg.dim_country add constraint dim_country_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_aircraft_type add constraint dim_aircraft_type_pkey primary key (id);
alter table rtg.dim_aircraft_type add constraint dim_aircraft_type_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_manufacturer add constraint dim_manufacturer_pkey primary key (id);
alter table rtg.dim_manufacturer add constraint dim_manufacturer_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_airline add constraint dim_airline_pkey primary key (id);
alter table rtg.dim_airline add constraint dim_airline_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_airport add constraint dim_airport_pkey primary key (id);
alter table rtg.dim_airport add constraint dim_airport_country_id_fkey foreign key (country_id) references rtg.dim_country(id);
alter table rtg.dim_airport add constraint dim_airport_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.dim_aircraft add constraint dim_aircraft_pkey primary key (id);
alter table rtg.dim_aircraft add constraint dim_aircraft_aircraft_type_id_fkey foreign key (aircraft_type_id) references rtg.dim_aircraft_type(id);
alter table rtg.dim_aircraft add constraint dim_aircraft_airline_id_fkey foreign key (airline_id) references rtg.dim_airline(id);
alter table rtg.dim_aircraft add constraint dim_aircraft_manufacturer_id_fkey foreign key (manufacturer_id) references rtg.dim_manufacturer(id);
alter table rtg.dim_aircraft add constraint dim_aircraft_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);

alter table rtg.fact_flights add constraint fact_flights_pkey primary key (id);
alter table rtg.fact_flights add constraint fact_flights_aircraft_id_fkey foreign key (aircraft_id) references rtg.dim_aircraft(id);
alter table rtg.fact_flights add constraint fact_flights_departure_airport_id_fkey foreign key (departure_airport_id) references rtg.dim_airport(id);
alter table rtg.fact_flights add constraint fact_flights_arrival_airport_id_fkey foreign key (arrival_airport_id) references rtg.dim_airport(id);
alter table rtg.fact_flights add constraint fact_flights_first_seen_on_id_fkey foreign key (first_seen_on_id) references rtg.dim_calendar(id);
alter table rtg.fact_flights add constraint fact_flights_last_seen_on_id_fkey foreign key (last_seen_on_id) references rtg.dim_calendar(id);
alter table rtg.fact_flights add constraint fact_flights_audit_id_fkey foreign key (audit_id) references rtg.dim_audit(id);


-- lookup

alter table lkp.fuel_consumptions add constraint fuel_consumptions_pkey primary key (id);
