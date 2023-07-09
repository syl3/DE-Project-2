from airflow.providers.amazon.aws.operators.redshift_sql import RedshiftSQLOperator


def create_external_table(
    event: str,
    s3_bucket_name: str,
):
    """
    Create an external table using the RedshiftSQLOperator

    Parameters :
        event : str
        s3_bucket_name : str

    Returns :
        task
    """
    task = RedshiftSQLOperator(
        task_id=f'{event}_create_external_table',
        sql=f"sql/{event}_create_external_table.sql",
        params={
            'event': event,
            's3_bucket_name': s3_bucket_name,
        },
        redshift_conn_id="redshift",
    )

    return task
