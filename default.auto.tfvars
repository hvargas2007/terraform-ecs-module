## GLOBAL VARIABLES
aws_region  = "us-east-1"
aws_profile = "default"
name_prefix = "myapp"
environment = "dev" # IMPORTANT: dev, staging or prod 

# PROJECT TAGS
project_tags = {
  Project   = "example-project"
  ManagedBy = "terraform"
  CreatedBy = "devops-team"
}

# ECS CLUSTER VARIABLES
uses_container_insights = false

# SECURITY GROUP RULES
ecs_ingress_rules = [
  {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
]

ecs_egress_rules = [
  {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

alb_ingress_rules = [
  {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

alb_egress_rules = [
  {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]


## ECR VARIABLES
amount_of_ecr_images_to_keep = "5"
scan_ecr_images_on_push      = false

## ALB CONFIGURATION
alb_internal               = false
enable_deletion_protection = false
deploy_nlb                 = false

## TARGET GROUP VARIABLES
ssl_policy          = "ELBSecurityPolicy-2016-08"
acm_certificate_arn = ""

## VPC
vpc_cidr = "10.0.0.0/16"

PrivateSubnet = [
  {
    name = "private-subnet-a"
    az   = "us-east-1a"
    cidr = "10.0.1.0/24"
  },
  {
    name = "private-subnet-b"
    az   = "us-east-1b"
    cidr = "10.0.2.0/24"
  }
]

PrivateSubnetDb = []

# VPC Configuration
use_transit_gateway     = false
create_public_subnets   = true
create_internet_gateway = true
create_nat_gateway      = true
single_nat_gateway      = true
transit_id              = ""

PublicSubnet = []