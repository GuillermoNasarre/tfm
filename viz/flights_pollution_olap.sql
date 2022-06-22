select 
	ac.registration "Aircraft Registration",
	ac.model "Aircraft Model", 
	ty.description "Aircraft Type",
	al.description "Aircraft Airline",
	cast (ty.engine_count as text) "Aircraft Engine Count",
	ty.engine_type "Aircraft Engine Type",
	ac."owner" "Airfract Owner",
	mf.description "Aircraft Manufacturer",
	de.description "Departure Airport",
	cd.description "Departure Country",
	ar.description "Arrival Airport",
	ca.description "Arrival Country",
	cf.full_date "Departure Date",
	ff.first_seen_at "Departure Time",
	cf.is_holiday "Departure Date Has Holiday",
	cf.holiday "Departure Date Holiday",
	cl.full_date  "Arrival Date",
	ff.last_seen_at "Arrival Time",
	cl.is_holiday "Arrival Date Has Holiday",
	cl.holiday "Arrival Date Holiday",
	ff.duration "Flight Duration (min)",
    ff.distance "Flown Distance (km)",
    ff.consumption "Consumed Fuel (kg)",
    ff.emissions "CO2 Emissions (tonnes)"
from rtg.fact_flights ff 
join rtg.dim_aircraft ac 
	on ff.aircraft_id = ac.id
join rtg.dim_airport de
	on ff.departure_airport_id = de.id
join rtg.dim_airport ar
	on ff.arrival_airport_id = ar.id
join rtg.dim_calendar cf
	on ff.first_seen_on_id = cf.id
join rtg.dim_calendar cl
	on ff.last_seen_on_id = cl.id
left join rtg.dim_aircraft_type ty
	on ac.aircraft_type_id = ty.id
left join rtg.dim_airline al
	on ac.airline_id = al.id 
left join rtg.dim_manufacturer mf
	on ac.manufacturer_id = mf.id
left join rtg.dim_country cd 
	on de.country_id = cd.id
left join rtg.dim_country ca
	on ar.country_id = ca.id