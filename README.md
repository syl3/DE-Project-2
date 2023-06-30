# Intro

This repo originated from [ankurchavda](https://github.com/ankurchavda/streamify), and I'm trying to replace the GCP infrastructure with AWS infrastructure and learn various services like Kafka and Spark Streaming in the process. It is still in progress and not yet completed.

## Original Architecture
![Alt text](img/Streamify-Architecture-Original.jpg?raw=true "Check Eventsim success or not")

# Steps

## 1. set up kafka.

```bash
ssh ubuntu@<KAFKA_PUBLIC_IP> -i ~/.ssh/de-project-2
```

```bash
git clone https://github.com/syl3/DE-Project-2.git && \
bash ~/DE-Project-2/scripts/vm_setup.sh && \
source .bashrc && \
export KAFKA_ADDRESS=<KAFKA_PUBLIC_IP> && \
cd ~/DE-Project-2/kafka && \
docker compose build && \
docker compose up
```

## 2. set up eventsim
in Kafka instance

run eventsim
```bash
bash ~/DE-Project-2/scripts/eventsim_startup.sh
```

Since eventsim run in docker detach mode, if you want to check logs, use the following command.
```bash
docker logs --follow million_events
```

To check whether Kafka has successfully received data from eventsim, you can forward port 9021. If successful, you will see the image below.

![Alt text](img/check_eventsim.png?raw=true "Check Eventsim success or not")



## 3. set up EMR.

### 3.1 Connect to master node.
```bash
ssh hadoop@<EMR_MASTER_PUBLIC_IP> -i ~/.ssh/de-project-2
```

### 3.2 Download git
```bash
sudo yum install git
```

### 3.3 Clone repo.
```bash
git clone https://github.com/syl3/DE-Project-2.git && \
cd DE-Project-2/spark_streaming
```

### 3.4 Export environment variables.
```bash
export KAFKA_ADDRESS=<KAFKA_PUBLIC_IP>
export AWS_S3_BUCKET=<BUCKET_NAME>
```

### 3.5 Start streaming
```bash
spark-submit \
--packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 \
stream_all_event.py
```


