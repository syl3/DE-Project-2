output "kafka_ip" {
  value = aws_instance.kafka.public_ip
}

output "bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.proj-data-lake.id
}

output "redshift_dns_name" {
  description = "Redshift DNS name."
  value       = aws_redshift_cluster.proj_redshift_cluster.dns_name
}

output "redshift_user" {
  description = "Redshift User name."
  value       = "sde_user"
}


output "redshift_password" {
  description = "Redshift password."
  value       = "sdeP0ssword0987"
}

