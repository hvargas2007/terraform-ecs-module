# Terraform ECS Module

This Terraform module provides a complete infrastructure for deploying applications on AWS ECS Fargate with Application Load Balancer (ALB), optional Network Load Balancer (NLB), auto-scaling, secrets management, and more.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Usage](#usage)
- [Useful Commands](#useful-commands)
- [Customization](#customization)

## 🎯 Overview

This module creates a complete AWS infrastructure including:

- **VPC** with public/private subnets, optional NAT Gateway and Internet Gateway
- **ECS Cluster** with Fargate support
- **Application Load Balancer (ALB)** for traffic distribution
- **Network Load Balancer (NLB)** optional for internal ALB
- **ECS Services** with Docker image versioning support
- **Auto Scaling** based on CPU and memory
- **Parameter Store** for secure secrets management
- **ECR (Elastic Container Registry)** for Docker images
- **CloudWatch Logs** for monitoring
- **Security Groups** configured for ALB and ECS
- **IAM Roles and Policies** required

## 📦 Prerequisites

1. **AWS CLI** configured with valid credentials
2. **Terraform** version 1.5.0 or higher
3. **Transit Gateway ID** (optional, if using Transit Gateway)
4. **AWS Permissions** needed to create resources

## 📁 Project Structure

```
terraform-ecs-module/
├── main.tf                 # Main configuration
├── variables.tf            # Variable definitions with validations
├── outputs.tf              # Module outputs
├── provider.tf             # AWS provider configuration
├── default.auto.tfvars     # Variable values
├── README.md               # This file
└── module/                 # Submodules
    ├── vpc/                # Virtual Private Cloud
    ├── alb/                # Application Load Balancer
    ├── alb_listener/       # ALB Listeners
    ├── alb_targetgroup/    # Target Groups
    ├── autoscaling/        # Auto Scaling
    ├── ecs/                # ECS Cluster
    ├── ecs_service/        # ECS Services with image_tag management
    ├── iam/                # IAM Roles and Policies
    ├── nlb/                # Network Load Balancer (optional)
    ├── parameter_store/    # AWS Systems Manager Parameter Store
    └── security_group/     # Security Groups
```

## ⚙️ Configuration

### 1. `default.auto.tfvars` File

This file contains all necessary variable values:

```hcl
## GLOBAL VARIABLES
aws_region     = "us-east-1"              # AWS Region
aws_profile    = "default"                # AWS CLI Profile
name_prefix    = "myapp"                  # Resource name prefix
environment    = "dev"                    # Environment: dev, staging or prod

# VPC CONFIGURATION
vpc_cidr = "10.0.0.0/16"                 # VPC CIDR
PrivateSubnet = [                         # Private subnets
  {
    name = "Private Subnet AZ1"
    az   = "us-east-1a"
    cidr = "10.0.1.0/24"
  },
  {
    name = "Private Subnet AZ2"
    az   = "us-east-1b"
    cidr = "10.0.2.0/24"
  }
]

# Optional network configuration
use_transit_gateway     = false           # Use Transit Gateway
create_public_subnets   = true           # Create public subnets
create_internet_gateway = true           # Create Internet Gateway
create_nat_gateway      = true           # Create NAT Gateway
single_nat_gateway      = true           # Single NAT Gateway

# PROJECT TAGS
project_tags = {
  Project   = "example-project"
  ManagedBy = "terraform"
  CreatedBy = "devops-team"
}

# ECS CLUSTER CONFIGURATION
uses_container_insights = false           # Container Insights (additional monitoring)

# SECURITY RULES FOR ECS
ecs_ingress_rules = [
  {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]        # Adjust to your VPC
  }
]

# ECR CONFIGURATION
amount_of_ecr_images_to_keep = 5         # Number of images to keep
scan_ecr_images_on_push      = false     # Vulnerability scanning

# ALB CONFIGURATION
alb_internal               = false        # true = Internal ALB
enable_deletion_protection = false        # Deletion protection

# NLB CONFIGURATION (optional)
deploy_nlb = false                        # Deploy NLB in front of internal ALB

# SSL/TLS CONFIGURATION
acm_certificate_arn = ""                 # ACM certificate ARN (leave empty for HTTP)
ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # SSL Policy
```

### 2. `main.tf` File

The main file orchestrates all modules:

```hcl
# Define local variables
locals {
  # Merge project tags with environment
  common_tags = merge(
    var.project_tags,
    {
      Environment = var.environment
    }
  )
  
  # Prefix with environment for resource names
  name_prefix_env = "${var.name_prefix}-${var.environment}"
}

# Base infrastructure modules
module "iam" { ... }
module "security_groups" { ... }
module "ecs" { ... }
module "alb" { ... }

# Service configuration
module "app_service" { ... }
```

## 🚀 Usage

### Initialization

1. **Clone or copy the module** to your project

2. **Configure variables** in `default.auto.tfvars`:
   ```bash
   # Edit with your values
   vim default.auto.tfvars
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

### Deployment

1. **Review the plan**:
   ```bash
   terraform plan
   ```

2. **Apply changes**:
   ```bash
   terraform apply
   ```

3. **Confirm** by typing `yes` when prompted

## 📝 Useful Commands

### Basic Terraform Commands

```bash
# Initialize the project (first time)
terraform init

# Update modules
terraform init -upgrade

# View execution plan
terraform plan

# Apply changes
terraform apply

# Apply without confirmation (use carefully!)
terraform apply -auto-approve

# Destroy all infrastructure
terraform destroy

# View current state
terraform show

# List resources in state
terraform state list

# View specific resource
terraform state show module.app_service.aws_ecs_service.service
```

### Validation Commands

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt

# View outputs
terraform output

# View specific output
terraform output alb_dns_name
```

## 🔧 Customization

### Adding a New Service

1. **Duplicate service section** in `main.tf`:
   ```hcl
   module "new_service" {
     source             = "./module/ecs_service"
     ecs_cluster_id     = module.ecs.ecs_cluster_id
     name_prefix        = local.name_prefix_env
     # ... more configuration
   }
   ```

2. **Create Parameter Store** for the new service:
   ```hcl
   module "new_parameters" {
     source       = "./module/parameter_store"
     service_name = "new"
     environment  = var.environment
     parameters = {
       API_KEY = "secret-value"
     }
   }
   ```

3. **Add Target Group and rules**:
   ```hcl
   module "new_targetgroup" {
     source         = "./module/alb_targetgroup"
     name_prefix    = local.name_prefix_env
     service_name   = "new"
     path_patterns  = ["/new/*"]
     # ... more configuration
   }
   ```

### Modifying Container Resources

In `main.tf`, adjust the `container_definitions` section:

```hcl
container_definitions = [
  {
    name           = "my-service"
    cpu            = 512         # CPU units (512 = 0.5 vCPU)
    memory         = 1024        # Memory in MB
    container_port = 8080        # Container port
    desired_count  = 2           # Number of tasks
    image_tag      = "v1.2.3"    # Docker image tag (default: "latest")
    environment = [
      {
        name  = "LOG_LEVEL"
        value = "debug"
      }
    ]
    secrets = [
      {
        name      = "DATABASE_URL"
        valueFrom = module.app_parameters.parameter_arns["DATABASE_URL"]
      }
    ]
    log_group_name    = "myapp/app/my-service"
    log_stream_prefix = "my-service"
  }
]
```

### Docker Image Version Control

The module allows controlling Docker image tags directly from service configuration:

```hcl
module "app_service" {
  source = "./module/ecs_service"
  # ... other configurations ...
  
  manage_task_definition = false  # Allows updating images without Terraform
  container_definitions = [
    {
      name      = "my-app"
      image_tag = "v1.0.0"  # Specify image tag
      # ... rest of configuration ...
    }
  ]
}
```

**Important note**: When `manage_task_definition = false`, Terraform will ignore task definition changes, allowing image updates via CI/CD without conflicts.

### Configure Auto Scaling

Modify values in autoscaling modules:

```hcl
module "app_autoscaling" {
  source              = "./module/autoscaling"
  service_name        = module.app_service.service_name
  cluster_name        = module.ecs.ecs_cluster_name
  min_capacity        = 1    # Minimum tasks
  max_capacity        = 10   # Maximum tasks
  cpu_target_value    = 60   # Target CPU %
  memory_target_value = 70   # Target Memory %
}
```

### Network Load Balancer (NLB)

When configuring `alb_internal = true` and `deploy_nlb = true`, the module will automatically create a public NLB that redirects traffic to the internal ALB:

```hcl
# In default.auto.tfvars
alb_internal = true    # Internal ALB
deploy_nlb   = true    # Create public NLB
```

## 📋 Available Outputs

The module provides the following outputs:

- `alb_dns_name`: Application Load Balancer DNS
- `alb_arn`: ALB ARN
- `nlb_dns_name`: Network Load Balancer DNS (if enabled)
- `ecs_cluster_name`: ECS cluster name
- `ecr_repository_urls`: Created ECR repository URLs

## 🔧 Troubleshooting

### Variable Validations

The module includes comprehensive validations for:
- AWS region format
- Valid CIDRs
- Port ranges
- Certificate ARNs
- Valid SSL policies
- Name prefixes

## 👤 Author

**Hermes Vargas**  
📧 hermesvargas200720@gmail.com  
💼 [LinkedIn Profile](https://www.linkedin.com/in/hermes-vargas-b1a529118/)