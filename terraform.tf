# ==============================================================================
# terraform.tf - Terraform Configuration & Provider Version Requirements
# ==============================================================================
# CONCEPT: Provider & Version Locking
# The 'terraform' block specifies the required Terraform CLI version and 
# external provider plugins (such as AWS) needed for this infrastructure project.
# Specifying version constraints ensures consistent behavior across different 
# environments and team members.
# ==============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
