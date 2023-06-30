import os
import pyarrow.csv as pv
import pyarrow.parquet as pq
from datetime import datetime
import psycopg2

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.hooks.postgres_hook import PostgresHook
from airflow.hooks.S3_hook import S3Hook
from airflow.models import Variable


from google.cloud import storage
from schema import schema

default_args = {'owner': 'airflow'}

AIRFLOW_HOME = os.environ.get('AIRFLOW_HOME', '/opt/airflow')

URL = 'https://github.com/ankurchavda/streamify/raw/main/dbt/seeds/songs.csv'
CSV_FILENAME = 'songs.csv'
PARQUET_FILENAME = CSV_FILENAME.replace('csv', 'parquet')

CSV_OUTFILE = f'{AIRFLOW_HOME}/{CSV_FILENAME}'
PARQUET_OUTFILE = f'{AIRFLOW_HOME}/{PARQUET_FILENAME}'
TABLE_NAME = 'songs'

BUCKET_NAME = Variable.get("BUCKET")


def convert_to_parquet(csv_file, parquet_file):
    if not csv_file.endswith('csv'):
        raise ValueError('The input file is not in csv format')

    table = pv.read_csv(csv_file)
    pq.write_table(table, parquet_file)


def upload_to_s3(
    bucket_name: str, key: str, file_name: str, remove_local: bool = False
) -> None:
    """
    Upload the downloaded file to S3
    """
    s3 = S3Hook()
    s3.load_file(filename=file_name, bucket_name=bucket_name, replace=True, key=key)
    if remove_local:
        if os.path.isfile(file_name):
            os.remove(file_name)


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
    download_songs_file_task = BashOperator(
        task_id="download_songs_file", bash_command=f"curl -sSLf {URL} > {CSV_OUTFILE}"
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
            "bucket_name": BUCKET_NAME,
            "remove_local": "true",
        },
    )

    remove_files_from_local_task = BashOperator(
        task_id='remove_files_from_local',
        bash_command=f'rm {CSV_OUTFILE} {PARQUET_OUTFILE}',
    )

    create_external_table_task = PostgresOperator(
        dag=dag,
        task_id="create_external_table",
        sql="sql/tmp.sql",
        postgres_conn_id="redshift",
    )

    (
        download_songs_file_task
        >> convert_to_parquet_task
        >> upload_to_s3_task
        >> remove_files_from_local_task
        >> create_external_table_task
    )
