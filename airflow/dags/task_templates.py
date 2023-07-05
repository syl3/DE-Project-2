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


def create_empty_table(event: str):
    """
    Create an empty table in Redshift using RedshiftSQLOperator

    Parameters :
        event : str

    Returns :
        task
    """
    task = RedshiftSQLOperator(
        task_id=f'{event}_create_empty_table',
        sql=f"sql/{event}_create_empty_table.sql",
        redshift_conn_id="redshift",
    )

    return task


# def insert_job(
#     event, insert_query_location, bigquery_dataset, gcp_project_id, timeout=300000
# ):
#     """
#     Run the insert query using BigQueryInsertJobOperator

#     Parameters :
#         insert_query : str
#         bigquery_dataset : str
#         gcp_project_id : str

#     Returns :
#         task
#     """

#     task = BigQueryInsertJobOperator(
#         task_id=f'{event}_execute_insert_query',
#         configuration={
#             'query': {'query': insert_query_location, 'useLegacySql': False},
#             'timeoutMs': timeout,
#             'defaultDataset': {
#                 'datasetId': bigquery_dataset,
#                 'projectId': gcp_project_id,
#             },
#         },
#     )

#     return task


# def delete_external_table(event, gcp_project_id, bigquery_dataset, external_table_name):
#     """
#     Delete table from Big Query using BigQueryDeleteTableOperator
#     Parameters:
#         gcp_project_id : str
#         bigquery_dataset : str
#         external_table_name : str

#     Returns:
#         task
#     """

#     task = BigQueryDeleteTableOperator(
#         task_id=f'{event}_delete_external_table',
#         deletion_dataset_table=f'{gcp_project_id}.{bigquery_dataset}.{external_table_name}',
#         ignore_if_missing=True,
#     )

#     return task
