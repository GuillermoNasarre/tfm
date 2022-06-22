from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from datetime import datetime, timedelta
import requests
import time


def etl_flights(flights, opsk_auth, db_url, job):
    
    if flights['extract']:
        
        # Start process
        process_start = datetime.now()
        print(f'Extracting dataset "{flights["dataset"]}"', end=': ', flush=True)
        
        # Start a Spark Session
        spark = SparkSession.builder\
                            .appName(f'{flights["dataset"]} ETL')\
                            .getOrCreate()
        
        # Import lookup tables
        db_properties = {'driver': 'org.postgresql.Driver'}
        
        lkp_cons = spark.read.jdbc(url=db_url, table='lkp.fuel_consumptions', properties=db_properties)
        lkp_cons = lkp_cons.withColumn('kms_start', lkp_cons.nm_start_exclusive * 1.852)\
                           .withColumn('kms_end', lkp_cons.nm_end * 1.852)
        
        lkp_airports = spark.read.jdbc(url=db_url, table='lkp.airport_coordinates', properties=db_properties)
        lkp_dep = lkp_airports.alias('lkp_dep')\
                    .withColumnRenamed('latitude', 'dep_lat')\
                    .withColumnRenamed('longitude', 'dep_lon')
        lkp_arr = lkp_airports.alias('lkp_arr')\
                    .withColumnRenamed('latitude', 'arr_lat')\
                    .withColumnRenamed('longitude', 'arr_lon')
        
        # Extract data (yesterday's flights)
        raw = []
        yesterday = process_start.date() - timedelta(days=1)
        first_time = datetime.combine(yesterday, datetime.min.time())
        for i in range(12):
            begin = first_time + timedelta(hours=i*2)
            end = begin + timedelta(hours=2)
            begin_unix = int(begin.timestamp())
            end_unix = int(end.timestamp())
            params = {'begin': begin_unix, 'end': end_unix}

            response = requests.get(flights['url'], params=params, auth=(opsk_auth['username'], opsk_auth['password']))
            raw.append(response.text)
            time.sleep(2)  # Courtesy wait for the server
        
        # Transform data
        df = spark.read.json(spark.sparkContext.parallelize(raw))
        job['records_extracted'] = job['records_extracted'] + df.count()

        rows = df.join(lkp_dep, df.estDepartureAirport == lkp_dep.icao)\
                 .join(lkp_arr, df.estArrivalAirport == lkp_arr.icao)\
                 .withColumn('duration', df.lastSeen - df.firstSeen)\
                 .withColumn('distance', measure_gcd(F.col('dep_lat'), F.col('dep_lon'), F.col('arr_lat'), F.col('arr_lon')))\
                 .join(lkp_cons, F.col('distance').between(lkp_cons.kms_start, lkp_cons.kms_end))\
                 .withColumn('consumption', F.col('fuel_tonnes'))\
                 .withColumn('emissions', F.round(F.col('consumption') * 3.16, 2))\
                 .withColumn('retention_period_end', F.lit(process_start.date() + timedelta(days=365*5)))\
                 .withColumn('job_id', F.lit(job['job_id']))\
                 .select(F.trim(F.lower(df.icao24)).alias('icao24'), 
                         F.from_unixtime(df.firstSeen, 'yyyy-MM-dd HH:mm:ss').alias('first_seen'), 
                         F.from_unixtime(df.lastSeen, 'yyyy-MM-dd HH:mm:ss').alias('last_seen'),  
                         F.col('duration'),
                         F.trim(F.upper(df.estDepartureAirport)).alias('departure_airport'), 
                         F.trim(F.upper(df.estArrivalAirport)).alias('arrival_airport'),
                         F.col('distance'),
                         F.col('consumption'),
                         F.col('emissions'),
                         F.col('retention_period_end'),
                         F.col('job_id')
                         )

        # Load data
        rows.write.format("jdbc")\
            .option("driver", "org.postgresql.Driver")\
            .option('url', f'jdbc:{db_url}')\
            .option('dbtable', f'{flights["schema"]}.{flights["table"]}') \
            .save()
        
        # Update job
        job['records_loaded'] = job['records_loaded'] + rows.count()

        # End process
        process_end = datetime.now()
        total_time = str(round((process_end - process_start).total_seconds() / 60, 2))
        print(total_time + 'min')
    
    else:
        print(f'Skipping "{flights["dataset"]}" ETL as per "input_mapping" request.')
              
        
def measure_gcd(origin_lat, origin_long, dest_lat, dest_long):
    
    # Calculate the Haversine distance [credit to: https://gist.github.com/pavlov99/bd265be244f8a84e291e96c5656ceb5c]
    a = (
        F.pow(F.sin(F.radians(dest_lat - origin_lat) / 2), 2) + \
        F.cos(F.radians(origin_lat)) * F.cos(F.radians(dest_lat)) * \
        F.pow(F.sin(F.radians(dest_long - origin_long) / 2), 2)
    )
    
    distance = F.round(F.atan2(F.sqrt(a), F.sqrt(-a + 1)) * 12742, 2)  # Great Circle Distance in Km
    
    # Apply correction factor [according to the ICAO Carbon Emissions Calculator Methodology
    distance = F.when(distance <= 550, distance + 50)\
                .when(distance >= 5500, distance + 125)\
                .otherwise(distance + 100)
        
    return distance


    