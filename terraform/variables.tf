## AWS account level config: region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

## AWS S3 bucket details
variable "bucket_prefix" {
  description = "Bucket prefix for our datalake"
  type        = string
  default     = "proj-data-lake-"
}

## AWS EMR node type and auto termination time (EMR is expensive!)
variable "instance_type" {
  description = "Instance type for EMR and EC2"
  type        = string
  default     = "m4.xlarge"
}


variable "auto_termination_timeoff" {
  description = "Auto EMR termination time(in idle seconds)"
  type        = number
  default     = 14400 # 4 hours
}