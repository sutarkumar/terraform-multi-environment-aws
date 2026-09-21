# Multi-Environment AWS Infrastructure with Terraform Workspaces

**Project Name:** `terraform-multi-environment-aws`  
**Purpose:** Exam Evaluation & Practical Viva Demonstration  

---

## 1. Project Purpose

This project demonstrates how to provision and manage isolated AWS cloud infrastructure across multiple environments (`dev` and `prod`) using **Terraform Workspaces** and environment-specific variable files (`terraform.tfvars.dev` and `terraform.tfvars.prod`).

Key principles implemented:
- **State Isolation**: Using Terraform Workspaces to separate state files per environment (`dev` vs. `prod`).
- **Dynamic Lookups**: Using AWS Data Blocks to look up network and image attributes instead of hardcoding resource IDs.
- **Dynamic Resource Counts**: Leveraging `count` to automatically adjust the number of deployed EC2 instances based on environment demand.
- **Standardized Tagging**: Tagging all resources with `Name`, `Environment`, and `Project` tags for governance and cost tracking.

---

## 2. Infrastructure Architecture

The configuration provisions the following AWS components:

```
                      +------------------------------------------+
                      |         AWS Cloud (us-east-1)            |
                      |                                          |
                      |  +------------------------------------+  |
                      |  |    Default VPC (Dynamically Fetched)|  |
                      |  |                                    |  |
                      |  |  +------------------------------+  |  |
                      |  |  | Security Group (Port 80/22)  |  |  |
                      |  |  +--------------+---------------+  |  |
                      |  |                 |                  |  |
                      |  |                 v                  |  |
                      |  |   EC2 Instances (Count: 1 or 3)    |  |
                      |  |   [App Server 1 ... App Server N]  |  |
                      |  +------------------------------------+  |
                      |                                          |
                      |  +------------------------------------+  |
                      |  | S3 Storage Bucket                  |  |
                      |  | (dev-storage / prod-storage)       |  |
                      |  +------------------------------------+  |
                      +------------------------------------------+
```

---

## 3. Key Terraform Concepts

### Terraform Workspaces
Terraform Workspaces allow managing multiple state files for a single configuration codebase. Each workspace maintains an isolated state (`terraform.tfstate.d/<workspace-name>/`), allowing independent deployments for `dev` and `prod` without state file conflicts.

### AWS Data Blocks
Data blocks retrieve real-time state or attributes from AWS directly, ensuring no IDs are hardcoded:
1. `aws_availability_zones`: Queries available Availability Zones.
2. `aws_vpc`: Queries the region's Default VPC.
3. `aws_subnets`: Dynamically lists all subnets inside the Default VPC.
4. `aws_ami`: Resolves the latest Amazon Linux 2023 AMI ID.

---

## 4. Input Variables Summary

Defined in [`variables.tf`](file:///Users/sk/terraform-multi-environment-aws/variables.tf):

| Variable Name | Type | Description | Default |
| :--- | :--- | :--- | :--- |
| `project_name` | `string` | Base project name for tagging/naming | `terraform-multi-environment-aws` |
| `environment` | `string` | Deployment environment (`dev` / `prod`) | *Required* |
| `region` | `string` | Target AWS region | `us-east-1` |
| `instance_type` | `string` | EC2 instance sizing | *Required* |
| `instance_count` | `number` | Total EC2 instances to provision | *Required* |
| `ami_name` | `string` | Pattern search for Amazon Machine Image | `al2023-ami-2023.*-x86_64` |
| `instance_name` | `string` | Base prefix for EC2 `Name` tags | *Required* |

---

## 5. Dev vs. Prod Environment Configuration

| Setting | Dev Environment (`terraform.tfvars.dev`) | Prod Environment (`terraform.tfvars.prod`) |
| :--- | :--- | :--- |
| `environment` | `"dev"` | `"prod"` |
| `instance_type` | `"t3.micro"` | `"t3.small"` |
| `instance_count` | `1` | `3` |
| `instance_name` | `"dev-app-server"` | `"prod-app-server"` |
| `region` | `"us-east-1"` | `"us-east-1"` |
| Target Workspace | `dev` | `prod` |

---

## 6. Step-by-Step Execution Guide

### Step 1: Initialize Terraform
Downloads required provider plugins (`hashicorp/aws`):
```bash
terraform init
```

### Step 2: Create & Manage Workspaces

Create the `dev` and `prod` workspaces:
```bash
# Create dev workspace
terraform workspace new dev

# Create prod workspace
terraform workspace new prod

# List all existing workspaces (* indicates current active workspace)
terraform workspace list
```

Switch between workspaces:
```bash
# Switch to dev workspace
terraform workspace select dev

# Switch to prod workspace
terraform workspace select prod
```

### Step 3: Format & Validate Code Syntax

Ensure strict formatting compliance:
```bash
terraform fmt
```

Validate syntactic correctness and schema integrity:
```bash
terraform validate
```

### Step 4: Generate Execution Plans (Dry Run)

Generate execution plan for **Development**:
```bash
terraform workspace select dev
terraform plan -var-file="terraform.tfvars.dev"
```

Generate execution plan for **Production**:
```bash
terraform workspace select prod
terraform plan -var-file="terraform.tfvars.prod"
```

### Step 5: Applying Changes (Production & Dev Deployment)

> [!CAUTION]
> Applying will provision real resources on AWS. Always confirm workspace and var-file match before running apply.

```bash
# Deploying to Dev
terraform workspace select dev
terraform apply -var-file="terraform.tfvars.dev"

# Deploying to Prod
terraform workspace select prod
terraform apply -var-file="terraform.tfvars.prod"
```

---


4. **Q: How do we verify tags are correct for dev vs prod?**  
   *A:* `var.environment` is passed into the tags block of all resources (`Environment = var.environment`), guaranteeing that tags dynamically reflect the targeted environment.
