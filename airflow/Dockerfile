# First-time build can take upto 10 mins.

FROM apache/airflow:2.4.2

ENV AIRFLOW_HOME=/opt/airflow

USER root
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get upgrade -y && \
    apt-get install -y git
RUN pip install --upgrade pip
# git gcc g++ -qqq

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Ref: https://airflow.apache.org/docs/docker-stack/recipes.html

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

WORKDIR $AIRFLOW_HOME

USER $AIRFLOW_UID