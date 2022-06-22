from datetime import datetime
import pandas as pd
import requests
import json
import io


def etl_dimensions(datasets, engine, job):
    for i in datasets.index:
        data = None

        if datasets.extract[i]:
        
            if datasets.format[i].lower() not in (['csv', 'json']):
                raise ValueError(f'Dataset #{i} "{datasets.dataset[i]}" cannot be extracted. "{datasets.format[i]}" is not a valid format.')
            
            else:
                process_start = datetime.now()
                print(f'Extracting dataset #{i} "{datasets.dataset[i]}"', end=': ', flush=True)
                response = requests.get(datasets.url[i])
                
                if datasets.format[i] == 'csv':
                    header = None if datasets.header_index[i] == 'None' else int(datasets.header_index[i])
                    data = pd.read_csv(io.StringIO(response.text), header=header)

                else:
                    data = pd.read_json(json.dumps(response.json()))
                    data = data.applymap(lambda x: json.dumps(x) if isinstance(x, dict) else x)
                    
                if data is not None:
                    job['records_extracted'] = job['records_extracted'] + len(data.index)

                    data = data.drop_duplicates()
                    data.columns = list(pd.read_sql_table(table_name=datasets.table[i], con=engine, schema=datasets.schema[i]))[:-4]
                    data['effective_date'] = datetime.now().strftime('%Y-%m-%d')
                    data['job_id'] = job['job_id']

                    data.to_sql(name=datasets.table[i],
                                con=engine,
                                schema=datasets.schema[i],
                                if_exists='append',
                                method='multi',
                                index=False)

                    job['records_loaded'] = job['records_loaded'] + len(data.index)
                    
                process_end = datetime.now()
                total_time = str(round((process_end - process_start).total_seconds() / 60, 2))
                print(total_time + 'min')

        else:
            print(f'Skipping ETL for dataset #{i} "{datasets.dataset[i]}" as per "input_mapping" request.')
            