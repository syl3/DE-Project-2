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