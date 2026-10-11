# ==============================================================================
# outputs.tf - Terraform Output Values
# ==============================================================================
# CONCEPT: Output Values
# Outputs export useful information from your Terraform state after execution.
# They allow inspecting created infrastructure attributes and passing values to 
# CI/CD tools or downstream modules.
# ==============================================================================

output "current_workspace" {
  description = "The active Terraform workspace (dev or prod)."
  value       = terraform.workspace
}

output "vpc_id" {
  description = "The ID of the dynamically selected default VPC."
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "The IDs of the subnets queried by the subnets data block."
  value       = data.aws_subnets.default.ids
}

output "selected_ami_id" {
  description = "The AMI ID dynamically selected based on search pattern."
  value       = data.aws_ami.amazon_linux.id
}

output "security_group_id" {
  description = "The ID of the application security group."
  value       = aws_security_group.app_sg.id
}

output "s3_bucket_name" {
  description = "The name of the created environment storage bucket."
  value       = aws_s3_bucket.app_storage.id
}

output "instance_count" {
  description = "The total number of EC2 instances provisioned."
  value       = length(aws_instance.app_server)
}

output "instance_ids" {
  description = "The IDs of all provisioned EC2 instances."
  value       = aws_instance.app_server[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses assigned to the provisioned EC2 instances."
  value       = aws_instance.app_server[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses assigned to the provisioned EC2 instances."
  value       = aws_instance.app_server[*].private_ip
}
