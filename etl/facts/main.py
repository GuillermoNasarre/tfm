from sqlalchemy import create_engine
from datetime import datetime
from functions import *
import pandas as pd
import json

# Start process
process_start = datetime.now()
run_date = str(process_start.date())
print('Process started at: ' + str(process_start))

# Define job
job_id = 'F-' + process_start.strftime("%y%m%d%H%M")
job = {'job_id': job_id, 'records_extracted': 0, 'records_loaded': 0, 'started_at': process_start}

# Import configuration and mapping files
with open('config.json') as config:
    cfg = json.loads(config.read())
    datasets = pd.read_csv(cfg['mappings']['input'], sep='\t', index_col='order')

# Prepare variables
db = cfg['connections']['db']
db_url = f"postgresql://{db['user']}:{db['password']}@{db['host']}:{db['port']}/{db['database']}"
opsk = cfg['connections']['opsk']
flights = datasets[datasets['dataset'] == 'flights'].to_dict('records')[0]
procedures = ['load_dim_audit()'].append(flights['procedure'])

# Create DB engine
engine = create_engine(db_url)
engine = engine.execution_options(isolation_level="AUTOCOMMIT")

# Run facts ETL
etl_flights(flights, opsk, db_url, job)

# Store job
job_end = datetime.now()
duration = (job_end - process_start).total_seconds()
job['ended_at'] = job_end
job['duration'] = duration
pd.DataFrame(job).to_sql(con=engine, schema='stg', name='jobs', if_exists='append', method='multi', index=False)

# Update the reporting schema
for procedure in procedures:
    engine.execute(f'call stg.{procedure}')

# Process end
process_end = datetime.now()
total_diff = round((process_end - process_start).total_seconds() / 60, 2)
print('Total process runtime: ' + str(total_diff) + 'min')