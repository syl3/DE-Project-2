# Intro

This project originated from [ankurchavda](https://github.com/ankurchavda/streamify). 

In this repository, I replaced the original GCP infrastructure with AWS infrastructure. I rewrote the SQL code used for dbt to be compatible with Redshift. I have also modified the Airflow DAG and fixed the issue of non-unique keys in wide_stream.sql. This is a comprehensive and rich repository that includes Kafka, Spark Streaming, Airflow, dbt, Terraform, Docker, and streaming and batch processing. I have learned a lot from it, and I appreciate [ankurchavda's](https://github.com/ankurchavda/streamify) sharing.


# Architecture
![Alt text](img/Architecture.png?raw=true "Architecture")


# Result
![Alt text](img/metabase_dashboard.png?raw=true "Metabase")
![Alt text](img/airflow.png?raw=true "Airflow")



# Steps

## Prerequiements  
1. [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
2. [Github account](https://github.com)  
3. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  
4. [AWS account](https://aws.amazon.com)  

## 1. Generate an SSH key pair for use in Terraform, which will be used to connect to EC2 instances later.

```bash
ssh-keygen -t rsa -f ~/.ssh/de-project-2
```

## 2. Launch the required AWS infrastructure using Terraform.

```bash
cd terraform && terraform apply -auto-approve
```

## 3. Once the EC2 instance is up and running, start configuring Kafka.

### 3.1 Connect to EC2.
```bash
ssh ubuntu@<KAFKA_PUBLIC_IP> -i ~/.ssh/de-project-2
```
### 3.2 Clone the repository, configure the instance and launch Kafka using Docker.
```bash
git clone https://github.com/syl3/DE-Project-2.git && \
bash ~/DE-Project-2/scripts/vm_setup.sh && \
source .bashrc && \
export KAFKA_ADDRESS=<KAFKA_PUBLIC_IP> && \
cd ~/DE-Project-2/kafka && \
docker compose build && \
docker compose up
```

## 4. After configuring Kafka, continue setting up eventsim on the same instance.

### 4.1 Run eventsim
```bash
bash ~/DE-Project-2/scripts/eventsim_startup.sh
```

Since eventsim run in docker detach mode, if you want to check logs, use the following command.
```bash
docker logs --follow million_events
```

To check whether Kafka has successfully received data from eventsim, you can forward port 9021. If successful, you will see the image below.

![Alt text](img/check_eventsim.png?raw=true "Check Eventsim success or not")



## 5. Once the EMR is up and running, start configuring Spark Streaming.

### 5.1 Connect to master node.
```bash
ssh hadoop@<EMR_MASTER_PUBLIC_IP> -i ~/.ssh/de-project-2
```

### 5.2 Download git
```bash
sudo yum install git
```

### 5.3 Clone repo.
```bash
git clone https://github.com/syl3/DE-Project-2.git && \
cd DE-Project-2/spark_streaming
```

### 5.4 Export environment variables.
```bash
export KAFKA_ADDRESS=<KAFKA_PUBLIC_IP>
export AWS_S3_BUCKET=<BUCKET_NAME>
```

### 5.5 Start streaming.
```bash
spark-submit \
--packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 \
stream_all_event.py
```

 ## 6. Once the EC2 is up and running, start configuring Airflow.

 ### 6.1 Connect to EC2.
 ```bash
ssh ubuntu@<AIRFLOW_PUBLIC_IP> -i ~/.ssh/de-project-2
```
### 6.2 Clone the repository, configure the instance and launch Airflow using Docker.
```bash
git clone https://github.com/syl3/DE-Project-2.git && \
bash ~/DE-Project-2/scripts/vm_setup.sh && \
source .bashrc && \
bash ~/DE-Project-2/scripts/airflow_startup.sh && cd ~/DE-Project-2/airflow
```

### 6.3 Adjust the security group of Redshift to allow all traffic from the Airflow public IP in the inbound rule.

### 6.4 Add the S3_BUCKET_NAME to the variables in the Admin section of the Airflow web UI, and Add the connection information for Redshift in the connections section.

## 7. Launch Metabase as a visualization and BI tool on the Airflow instance.

```bash
cd metabase/ && docker compose up -d
```

## 8. Future work.
1. CI/CD pipeline.