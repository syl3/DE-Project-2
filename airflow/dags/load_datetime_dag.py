import os
import pyarrow.csv as pv
import pyarrow.parquet as pq
from datetime import datetime
import pandas as pd

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.hooks.S3_hook import S3Hook
from airflow.models import Variable
from airflow.providers.amazon.aws.operators.redshift_sql import RedshiftSQLOperator

default_args = {'owner': 'airflow'}

AIRFLOW_HOME = os.environ.get('AIRFLOW_HOME', '/opt/airflow')

CSV_FILENAME = 'datetime.csv'
PARQUET_FILENAME = CSV_FILENAME.replace('csv', 'parquet')

CSV_OUTFILE = f'{AIRFLOW_HOME}/{CSV_FILENAME}'
PARQUET_OUTFILE = f'{AIRFLOW_HOME}/{PARQUET_FILENAME}'
TABLE_NAME = 'datetime'

S3_BUCKET_NAME = Variable.get("S3_BUCKET_NAME")

S3_PATH = f's3://{S3_BUCKET_NAME}/stage/datetime/'


def create_datetime_data():
    # define start date and end date.
    start_date = datetime(2021, 1, 1)
    end_date = datetime(2025, 1, 1)

    # generate date
    date_range = pd.date_range(start=start_date, end=end_date, freq='H')

    # create empty dataframe
    data = pd.DataFrame(
        columns=[
            'date_key',
            'date',
            'day_of_week',
            'day_of_month',
            'week_of_year',
            'month',
            'year',
            'weekend_flag',
        ]
    )

    # generate data
    data['date_key'] = data['date'].apply(datetime.timestamp).astype(int)
    data['date'] = date_range
    data['day_of_week'] = data['date'].dt.dayofweek
    data['day_of_month'] = data['date'].dt.day
    data['week_of_year'] = data['date'].dt.isocalendar().week
    data['month'] = data['date'].dt.month
    data['year'] = data['date'].dt.year
    data['weekend_flag'] = 0
    data.loc[data['day_of_week'] >= 5, 'weekend_flag'] = 1

    data.to_csv('datetime.csv', index=False)


def convert_to_parquet(csv_file, parquet_file):
    if not csv_file.endswith('csv'):
        raise ValueError('The input file is not in csv format')

    table = pv.read_csv(csv_file)
    pq.write_table(table, parquet_file)


def upload_to_s3(bucket_name: str, key: str, file_name: str) -> None:
    """
    Upload the downloaded file to S3
    """
    s3 = S3Hook()
    s3.load_file(filename=file_name, bucket_name=bucket_name, replace=True, key=key)


with DAG(
    dag_id=f'load_songs_dag',
    default_args=default_args,
    description=f'Execute only once to create songs table in bigquery',
    schedule_interval="@once",  # At the 5th minute of every hour
    start_date=datetime(2022, 3, 20),
    end_date=datetime(2022, 3, 20),
    catchup=True,
    tags=['streamify'],
) as dag:
    create_datetime_data_task = PythonOperator(
        task_id='convert_to_parquet',
        python_callable=create_datetime_data,
    )

    convert_to_parquet_task = PythonOperator(
        task_id='convert_to_parquet',
        python_callable=convert_to_parquet,
        op_kwargs={'csv_file': CSV_OUTFILE, 'parquet_file': PARQUET_OUTFILE},
    )

    upload_to_s3_task = PythonOperator(
        task_id='upload_to_s3',
        python_callable=upload_to_s3,
        op_kwargs={
            "file_name": PARQUET_OUTFILE,
            "key": f"stage/{TABLE_NAME}/{PARQUET_FILENAME}",
            "bucket_name": S3_BUCKET_NAME,
            "remove_local": "true",
        },
    )

    remove_files_from_local_task = BashOperator(
        task_id='remove_files_from_local',
        bash_command=f'rm {CSV_OUTFILE} {PARQUET_OUTFILE}',
    )

    create_external_table_task = RedshiftSQLOperator(
        dag=dag,
        task_id="create_external_table",
        sql="sql/datetime_create_external_table.sql",
        params={'s3_path': S3_PATH},
        redshift_conn_id="redshift",
    )

    (
        create_datetime_data_task
        >> convert_to_parquet_task
        >> upload_to_s3_task
        >> remove_files_from_local_task
        >> create_external_table_task
    )
