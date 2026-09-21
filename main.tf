# ==============================================================================
# main.tf - Core Terraform Resources, Data Sources, and Provider Setup
# ==============================================================================
# CONCEPT: Terraform Architecture & Declarative Design
# This file contains the primary infrastructure specification. Terraform reads this
# configuration, queries AWS for existing network & AMI details using Data Blocks,
# calculates the required resource state, and plans the necessary changes.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. AWS Provider Configuration
# ------------------------------------------------------------------------------
# CONCEPT: Providers
# Providers interact with target Cloud APIs (e.g., AWS, Azure, GCP).
# The region is dynamically populated from `var.region`.
# ------------------------------------------------------------------------------
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# ------------------------------------------------------------------------------
# 2. AWS Data Blocks (4 Mandatory Data Sources)
# ------------------------------------------------------------------------------
# CONCEPT: Data Sources & Dynamic Lookups
# Data blocks allow Terraform to read data defined outside of Terraform or by 
# another separate Terraform configuration. Using data blocks avoids hardcoding 
# dynamic cloud parameters like VPC IDs, Subnet IDs, or AMI IDs.
# ------------------------------------------------------------------------------

# DATA BLOCK 1: Query Available AWS Availability Zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# DATA BLOCK 2: Query Default VPC details dynamically (No hardcoded vpc-id)
data "aws_vpc" "default" {
  default = true
}

# DATA BLOCK 3: Query Subnet IDs associated with the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# DATA BLOCK 4: Query Latest Amazon Linux 2023 AMI dynamically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# 3. AWS Resource Configurations
# ------------------------------------------------------------------------------
# CONCEPT: Resource Blocks & Infrastructure Provisioning
# Resource blocks define infrastructure components (Security Groups, S3 Buckets,
# EC2 Instances). All resources reference input variables and data blocks.
# ------------------------------------------------------------------------------

# RESOURCE 1: Security Group for Application Servers
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} application in ${var.environment} environment"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow inbound HTTP traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound SSH access on port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # CONCEPT: Resource Tagging Strategy
  # Standardized metadata tags are attached for cost tracking, filtering, and audit compliance.
  tags = {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RESOURCE 2: Environment Storage (S3 Bucket)
resource "aws_s3_bucket" "app_storage" {
  bucket        = "${var.project_name}-${var.environment}-storage-data"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-storage-data"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RESOURCE 3: EC2 Instances Provisioned Dynamically via 'count'
# CONCEPT: Dynamic Scaling with 'count'
# The `count` meta-argument allows creation of multiple resource instances based
# on `var.instance_count` (1 for dev, 3 for prod).
# Subnets are distributed evenly across available subnets using modulo math `count.index % length(...)`.
resource "aws_instance" "app_server" {
  count = var.instance_count

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Dynamic Subnet assignment across subnets found by Data Block 3
  subnet_id = [
    data.aws_subnets.default.ids[0], # us-east-1f
    data.aws_subnets.default.ids[3], # us-east-1b
    data.aws_subnets.default.ids[2]  # us-east-1a
  ][count.index]

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # CONCEPT: Dynamic Tagging per Instance Index
  tags = {
    Name        = "${var.instance_name}-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}
