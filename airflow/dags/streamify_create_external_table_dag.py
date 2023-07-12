from datetime import datetime
from airflow import DAG
from airflow.models import Variable
from schema import schema
from task_templates import create_external_table


EVENTS = [
    'listen_events',
    'page_view_events',
    'auth_events',
]  # we have data coming in from three events

S3_BUCKET_NAME = Variable.get("S3_BUCKET_NAME")


default_args = {'owner': 'airflow'}

with DAG(
    dag_id=f'streamify_dag',
    default_args=default_args,
    description=f'Hourly data pipeline to generate dims and facts for streamify',
    schedule_interval="@once",  # At the 5th minute of every hour
    start_date=datetime(2022, 3, 26, 18),
    catchup=False,
    max_active_runs=1,
    tags=['streamify'],
) as dag:
    for event in EVENTS:
        staging_table_name = event
        events_schema = schema[event]

        create_external_table_task = create_external_table(
            event,
            S3_BUCKET_NAME,
        )

        (create_external_table_task)
