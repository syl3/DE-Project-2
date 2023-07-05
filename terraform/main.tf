terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    redshift = {
      source  = "brainly/redshift"
      version = "1.0.2"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region  = var.aws_region
  profile = "terraform"
}

resource "aws_vpc" "de_proj_2_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "proj"
  }
}

resource "aws_subnet" "de_proj_2_public_subnet" {
  vpc_id                  = aws_vpc.de_proj_2_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  #availability_zone       = "us-east-1a"

  tags = {
    Name = "de_proj_2-public"
  }
}


resource "aws_internet_gateway" "de_proj_2_internet_gateway" {
  vpc_id = aws_vpc.de_proj_2_vpc.id

  tags = {
    Name = "de_proj_2-igw"
  }
}

resource "aws_route_table" "de_proj_2_public_rt" {
  vpc_id = aws_vpc.de_proj_2_vpc.id

  tags = {
    Name = "de_proj_2_public_rt"
  }
}

resource "aws_route" "de_proj_2_route" {
  route_table_id         = aws_route_table.de_proj_2_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.de_proj_2_internet_gateway.id
}

resource "aws_route_table_association" "de_proj_2_public_assoc" {
  subnet_id      = aws_subnet.de_proj_2_public_subnet.id
  route_table_id = aws_route_table.de_proj_2_public_rt.id
}

resource "aws_security_group" "de_proj_2_sg" {
  name        = "de_proj_2_sg"
  description = "de_proj_2 security group"
  vpc_id      = aws_vpc.de_proj_2_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "de_proj_2_auth" {
  key_name   = "de_proj_2_key"
  public_key = file("~/.ssh/de-project-2.pub")
}

# IAM role for EC2 to connect to AWS Redshift, S3, & EMR
resource "aws_iam_role" "proj_ec2_iam_role" {
  name = "proj_ec2_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2", "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"]
}

resource "aws_iam_instance_profile" "proj_ec2_iam_role_instance_profile" {
  name = "proj_ec2_iam_role_instance_profile"
  role = aws_iam_role.proj_ec2_iam_role.name
}




resource "aws_instance" "kafka" {
  instance_type          = "t2.xlarge"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.de_proj_2_auth.id
  vpc_security_group_ids = [aws_security_group.de_proj_2_sg.id]
  subnet_id              = aws_subnet.de_proj_2_public_subnet.id
  user_data              = file("userdata.tpl")

  iam_instance_profile = aws_iam_instance_profile.proj_ec2_iam_role_instance_profile.id

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "kafka-node"
  }

}


resource "aws_instance" "airflow" {
  instance_type          = "t2.xlarge"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.de_proj_2_auth.id
  vpc_security_group_ids = [aws_security_group.de_proj_2_sg.id]
  subnet_id              = aws_subnet.de_proj_2_public_subnet.id
  user_data              = file("userdata.tpl")

  iam_instance_profile = aws_iam_instance_profile.proj_ec2_iam_role_instance_profile.id

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "airflow-node"
  }

}


# Create our S3 bucket (Datalake)
resource "aws_s3_bucket" "proj-data-lake" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "proj-data-lake" {
  bucket = aws_s3_bucket.proj-data-lake.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "proj-data-lake" {
  bucket = aws_s3_bucket.proj-data-lake.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "proj-data-lake-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.proj-data-lake,
    aws_s3_bucket_public_access_block.proj-data-lake,
  ]

  bucket = aws_s3_bucket.proj-data-lake.id
  acl    = "public-read-write"
}



resource "aws_security_group" "de_proj_2_emr_sg" {
  name        = "de_proj_2_emr_sg"
  description = "de_proj_2 emr security group"
  vpc_id      = aws_vpc.de_proj_2_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




#Set up EMR
resource "aws_emr_cluster" "proj_emr_cluster" {
  name                   = "proj_emr_cluster"
  release_label          = "emr-6.5.0"
  applications           = ["Spark", "Hadoop"]
  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  service_role           = "EMR_DefaultRole"
  termination_protection = false
  auto_termination_policy {
    idle_timeout = var.auto_termination_timeoff
  }

  ec2_attributes {
    instance_profile = aws_iam_instance_profile.proj_ec2_iam_role_instance_profile.id

    subnet_id = aws_subnet.de_proj_2_public_subnet.id
    key_name  = aws_key_pair.de_proj_2_auth.id

    additional_master_security_groups = aws_security_group.de_proj_2_emr_sg.id
    additional_slave_security_groups  = aws_security_group.de_proj_2_emr_sg.id
  }


  master_instance_group {
    instance_type  = var.instance_type
    instance_count = 1
    name           = "Master - 1"

    ebs_config {
      size                 = 32
      type                 = "gp2"
      volumes_per_instance = 2
    }
  }

  core_instance_group {
    instance_type  = var.instance_type
    instance_count = 2
    name           = "Core - 2"

    ebs_config {
      size                 = "32"
      type                 = "gp2"
      volumes_per_instance = 2
    }
  }
}



# IAM role for Redshift to be able to read data from S3 via Spectrum
resource "aws_iam_role" "proj_redshift_iam_role" {
  name = "sde_redshift_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"]
}


# Set up Redshift
resource "aws_redshift_cluster" "proj_redshift_cluster" {
  cluster_identifier  = "proj-redshift-cluster"
  master_username     = var.redshift_user
  master_password     = var.redshift_password
  port                = 5439
  node_type           = var.redshift_node_type
  cluster_type        = "single-node"
  iam_roles           = [aws_iam_role.proj_redshift_iam_role.arn]
  skip_final_snapshot = true
}

# Create Redshift spectrum schema
provider "redshift" {
  host     = aws_redshift_cluster.proj_redshift_cluster.dns_name
  username = var.redshift_user
  password = var.redshift_password
  database = "dev"
}

# External schema using AWS Glue Data Catalog
resource "redshift_schema" "external_from_glue_data_catalog" {
  name  = "spectrum"
  owner = var.redshift_user
  external_schema {
    database_name = "spectrum"
    data_catalog_source {
      region                                 = var.aws_region
      iam_role_arns                          = [aws_iam_role.proj_redshift_iam_role.arn]
      create_external_database_if_not_exists = true
    }
  }
}

