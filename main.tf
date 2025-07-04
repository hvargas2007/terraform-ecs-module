################################################################################
# BASE INFRASTRUCTURE
################################################################################

locals {
  # Merge project tags with environment
  common_tags = merge(
    var.project_tags,
    {
      Environment = var.environment
    }
  )

  # Name prefix with environment
  name_prefix_env = "${var.name_prefix}-${var.environment}"
}

################################################################################
# VPC MODULE
################################################################################

module "vpc" {
  source = "./module/vpc"

  name_prefix     = "${var.name_prefix}-${var.environment}"
  vpc_cidr   = var.vpc_cidr
  PrivateSubnet   = var.PrivateSubnet
  PrivateSubnetDb = var.PrivateSubnetDb
  PublicSubnet    = var.PublicSubnet
  project-tags    = local.common_tags

  # Conditional resource creation
  use_transit_gateway     = var.use_transit_gateway
  transit_id              = var.transit_id
  create_public_subnets   = var.create_public_subnets
  create_internet_gateway = var.create_internet_gateway
  create_nat_gateway      = var.create_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
}

# IAM Roles
module "iam" {
  source      = "./module/iam"
  name_prefix = local.name_prefix_env
}

# Security Groups for ECS Tasks
module "security_groups" {
  source        = "./module/security_group"
  name_prefix   = "${var.name_prefix}-ecs-${var.environment}"
  project_tags  = local.common_tags
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.ecs_ingress_rules
  egress_rules  = var.ecs_egress_rules
}

# Security Group for ALB
module "alb_security_group" {
  source        = "./module/security_group"
  name_prefix   = "${var.name_prefix}-alb-${var.environment}"
  project_tags  = local.common_tags
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.alb_ingress_rules
  egress_rules  = var.alb_egress_rules
}

# ECS Cluster
module "ecs" {
  source                  = "./module/ecs"
  name_prefix             = "${var.name_prefix}-cluster-${var.environment}"
  project_tags            = local.common_tags
  uses_container_insights = var.uses_container_insights
}

# Application Load Balancer
module "alb" {
  source                     = "./module/alb"
  name_prefix                = "${var.name_prefix}-alb-${var.environment}"
  project_tags               = local.common_tags
  subnets                    = var.create_public_subnets ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids
  security_groups            = [module.alb_security_group.ecs_sg_id]
  internal                   = var.alb_internal
  enable_deletion_protection = var.enable_deletion_protection
}

# ALB Listeners (HTTP/HTTPS)
module "alb_listeners" {
  source              = "./module/alb_listener"
  alb_arn             = module.alb.alb_arn
  https_enabled       = length(var.acm_certificate_arn) > 0
  acm_certificate_arn = var.acm_certificate_arn
  ssl_policy          = var.ssl_policy
  project_tags        = local.common_tags
}

################################################################################
# EXAMPLE SERVICE
################################################################################

# Parameter Store
module "app_parameters" {
  source       = "./module/parameter_store"
  service_name = "app"
  environment  = var.environment
  project_tags = local.common_tags

  parameters = {
    "/app/database_password" = "dummy_password"
    "/app/api_key"          = "dummy_api_key"
  }
}

# Target Group
module "app_targetgroup" {
  source            = "./module/alb_targetgroup"
  name_prefix       = "${var.name_prefix}-tg-app-${var.environment}"
  service_name      = "${var.name_prefix}-app-service-${var.environment}"
  vpc_id            = module.vpc.vpc_id
  container_port    = 80
  listener_arn      = length(var.acm_certificate_arn) > 0 ? module.alb_listeners.https_listener_arn : module.alb_listeners.http_listener_arn
  rule_priority     = 100
  path_patterns     = ["/"]
  host_headers      = []
  health_check_path = "/"
  project_tags      = local.common_tags
}

# ECS Service
module "app_service" {
  source                 = "./module/ecs_service"
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  execution_role_arn     = module.iam.execution_role_arn
  task_role_arn          = module.iam.task_role_arn
  ecs_sg_id              = module.security_groups.ecs_sg_id
  tg_arn                 = module.app_targetgroup.target_group_arn
  aws_region             = var.aws_region
  name_prefix            = local.name_prefix_env
  project_tags           = local.common_tags
  vpc_id                 = module.vpc.vpc_id
  subnet_private         = module.vpc.private_subnet_ids
  task_definition_name   = "${var.name_prefix}-app-td-${var.environment}"
  manage_task_definition = false
  container_definitions = [
    {
      name             = "${var.name_prefix}-app-${var.environment}"
      cpu              = 256
      memory           = 512
      container_port   = 80
      desired_count    = 1
      image_tag        = "latest"
      environment = [
        {
          name  = "ENV"
          value = var.environment
        }
      ]
      secrets = []
      root_directory_path = "/"
      log_group_name      = "${var.name_prefix}/app"
      log_stream_prefix   = "app"
    }
  ]
  name_registry                = "${var.name_prefix}-app-${var.environment}"
  amount_of_ecr_images_to_keep = var.amount_of_ecr_images_to_keep
  scan_ecr_images_on_push      = var.scan_ecr_images_on_push
}

# Autoscaling
module "app_autoscaling" {
  source              = "./module/autoscaling"
  service_name        = module.app_service.service_name
  cluster_name        = module.ecs.ecs_cluster_name
  min_capacity        = 1
  max_capacity        = 4
  cpu_target_value    = 70
  memory_target_value = 80
}