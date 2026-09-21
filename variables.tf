# ==============================================================================
# variables.tf - Input Variable Definitions
# ==============================================================================
# CONCEPT: Input Variables
# Variables allow Terraform modules to be parameterized. Instead of hardcoding
# values like instance sizes, counts, or region names, variables allow the same
# configuration to be reused across multiple environments (dev, prod, etc.).
# ==============================================================================

variable "project_name" {
  type        = string
  description = "The overarching project name used for resource naming and tagging standardizations."
  default     = "terraform-multi-environment-aws"
}

variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, prod). Dictates workspace context and resource tags."
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed."
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type (e.g., t3.micro for dev, t3.small for prod)."
}

variable "instance_count" {
  type        = number
  description = "The number of EC2 instances to provision for this environment."
}

variable "ami_name" {
  type        = string
  description = "The AMI name search pattern used to dynamically look up the Amazon Machine Image."
  default     = "al2023-ami-2023.*-x86_64"
}

variable "instance_name" {
  type        = string
  description = "Base name tag prefix for EC2 instances."
}
