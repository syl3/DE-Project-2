from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.models import Variable
from schema import schema
from task_templates import (
    create_external_table,
    # create_empty_table,
    # insert_job,
    # delete_external_table,
)


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
    schedule_interval="5 * * * *",  # At the 5th minute of every hour
    start_date=datetime(2022, 3, 26, 18),
    catchup=False,
    max_active_runs=1,
    tags=['streamify'],
) as dag:
    # initate_dbt_task = BashOperator(
    #     task_id='dbt_initiate',
    #     bash_command='cd /dbt && dbt deps && dbt seed --select state_codes --profiles-dir . --target prod',
    # )

    # execute_dbt_task = BashOperator(
    #     task_id='dbt_streamify_run',
    #     bash_command='cd /dbt && dbt deps && dbt run --profiles-dir . --target prod',
    # )

    for event in EVENTS:
        staging_table_name = event
        insert_query = (
            f"{{% include 'sql/{event}.sql' %}}"  # extra {} for f-strings escape
        )
        events_schema = schema[event]

        create_external_table_task = create_external_table(
            event,
            S3_BUCKET_NAME,
        )

        # create_empty_table_task = create_empty_table(
        #     event,
        # )

        # execute_insert_query_task = insert_job(
        #     event,
        #     insert_query,
        #     BIGQUERY_DATASET,
        #     # GCP_PROJECT_ID
        # )

        # delete_external_table_task = delete_external_table(
        #     event,
        #     # GCP_PROJECT_ID,
        #     BIGQUERY_DATASET,
        #     external_table_name,
        # )

        (
            create_external_table_task
            # >> create_empty_table_task
            # >> execute_insert_query_task
            # >> delete_external_table_task
            # >> initate_dbt_task
            # >> execute_dbt_task
        )
