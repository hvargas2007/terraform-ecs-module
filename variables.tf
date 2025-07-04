## GLOBAL VARIABLES
variable "aws_profile" {
  description = "[REQUIRED] AWS Profile."
  type        = string

  validation {
    condition     = length(var.aws_profile) > 0
    error_message = "The aws_profile cannot be empty."
  }
}

variable "name_prefix" {
  description = "[REQUIRED] Prefix for resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name_prefix)) && length(var.name_prefix) <= 20
    error_message = "The name_prefix must start with a letter, contain only letters, numbers and hyphens, and be at most 20 characters."
  }
}

variable "environment" {
  description = "Deployment environment (dev, qa, prd)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prd"], var.environment)
    error_message = "The environment must be dev, qa or prd."
  }
}

variable "aws_region" {
  description = "[REQUIRED] AWS Region."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "The AWS region must have a valid format (e.g. us-east-1, eu-west-2)."
  }
}

variable "project_tags" {
  description = "[REQUIRED] Project tags for resources."
  type        = map(string)

  validation {
    condition     = length(var.project_tags) > 0
    error_message = "At least one tag must be provided."
  }
}

## VPC MODULE VARIABLES
variable "vpc_cidr" {
  description = "[REQUIRED] CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid CIDR block."
  }
}

variable "PrivateSubnet" {
  description = "[REQUIRED] List of private subnets configuration"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))

  validation {
    condition     = length(var.PrivateSubnet) >= 2
    error_message = "At least 2 private subnets are required for high availability."
  }
}

variable "PrivateSubnetDb" {
  description = "[REQUIRED] List of database subnets configuration"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))

  validation {
    condition     = length(var.PrivateSubnetDb) >= 2
    error_message = "At least 2 database subnets are required for high availability."
  }
}

variable "PublicSubnet" {
  description = "List of public subnets configuration (required when create_public_subnets is true)"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default = []

  validation {
    condition = alltrue([
      for subnet in var.PublicSubnet :
      can(cidrhost(subnet.cidr, 0)) &&
      length(subnet.name) > 0 &&
      can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]?$", subnet.az))
    ])
    error_message = "Each subnet must have a valid CIDR, non-empty name, and valid availability zone format."
  }
}

variable "use_transit_gateway" {
  description = "Whether to use Transit Gateway for routing"
  type        = bool
  default     = true
}

variable "create_public_subnets" {
  description = "Whether to create public subnets"
  type        = bool
  default     = false
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "transit_id" {
  description = "Transit Gateway ID (required when use_transit_gateway is true)"
  type        = string
  default     = ""

  validation {
    condition     = var.transit_id == "" || can(regex("^tgw-[a-f0-9]{8,17}$", var.transit_id))
    error_message = "The transit_id must be empty or a valid Transit Gateway ID (e.g., tgw-0123456789abcdef)."
  }
}


## ECS CLUSTER VARIABLES
variable "uses_container_insights" {
  description = "[REQUIRED] Enable Container Insights."
  type        = bool
}

## SECURITY GROUP VARIABLES
variable "ecs_ingress_rules" {
  description = "Ingress rules for the ECS tasks security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for rule in var.ecs_ingress_rules :
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port
    ])
    error_message = "Ports must be between 0 and 65535, and from_port must be less than or equal to to_port."
  }
}

variable "ecs_egress_rules" {
  description = "Egress rules for the ECS tasks security group"
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for rule in var.ecs_egress_rules :
      rule.from_port >= -1 && rule.from_port <= 65535 &&
      rule.to_port >= -1 && rule.to_port <= 65535
    ])
    error_message = "Ports must be between -1 and 65535 for egress rules."
  }
}

variable "amount_of_ecr_images_to_keep" {
  description = "[REQUIRED] The number of images to keep in the ECR repository."
  type        = number

  validation {
    condition     = var.amount_of_ecr_images_to_keep >= 1 && var.amount_of_ecr_images_to_keep <= 1000
    error_message = "The number of images to keep must be between 1 and 1000."
  }
}

variable "scan_ecr_images_on_push" {
  description = "[REQUIRED] Whether to scan ECR images on push."
  type        = bool
}

## TARGET GROUP VARIABLE

variable "ssl_policy" {
  description = "SSL security policy for the ALB"
  type        = string

  validation {
    condition = contains([
      "ELBSecurityPolicy-2016-08",
      "ELBSecurityPolicy-TLS-1-0-2015-04",
      "ELBSecurityPolicy-TLS-1-1-2017-01",
      "ELBSecurityPolicy-TLS-1-2-2017-01",
      "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
      "ELBSecurityPolicy-FS-2018-06",
      "ELBSecurityPolicy-FS-1-1-2019-08",
      "ELBSecurityPolicy-FS-1-2-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2019-08",
      "ELBSecurityPolicy-FS-1-2-Res-2020-10",
      "ELBSecurityPolicy-TLS13-1-2-2021-06",
      "ELBSecurityPolicy-TLS13-1-2-Res-2021-06",
      "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06",
      "ELBSecurityPolicy-TLS13-1-2-Ext2-2021-06",
      "ELBSecurityPolicy-TLS13-1-3-2021-06",
      "ELBSecurityPolicy-TLS13-1-1-2021-06",
      "ELBSecurityPolicy-TLS13-1-0-2021-06"
    ], var.ssl_policy)
    error_message = "The ssl_policy must be a valid AWS ALB SSL policy."
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (optional, leave empty for HTTP only)"
  type        = string

  validation {
    condition     = var.acm_certificate_arn == "" || can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-f0-9-]+$", var.acm_certificate_arn))
    error_message = "The acm_certificate_arn must be empty or a valid ACM certificate ARN."
  }
}


variable "alb_internal" {
  description = "Whether the ALB should be internal"
  type        = bool
}

variable "deploy_nlb" {
  description = "Deploy a Network Load Balancer in front of the internal ALB (only applies when alb_internal = true)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
}

variable "alb_ingress_rules" {
  description = "Ingress rules for the ALB security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for rule in var.alb_ingress_rules :
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535 &&
      rule.from_port <= rule.to_port &&
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "ALB ingress rules must have valid ports (0-65535), from_port <= to_port, and protocol must be tcp, udp, icmp, or -1."
  }
}

variable "alb_egress_rules" {
  description = "Egress rules for the ALB security group"
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for rule in var.alb_egress_rules :
      rule.from_port >= -1 && rule.from_port <= 65535 &&
      rule.to_port >= -1 && rule.to_port <= 65535 &&
      (rule.from_port == -1 ? rule.to_port == -1 : rule.from_port <= rule.to_port) &&
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "ALB egress rules must have valid ports (-1 to 65535), matching -1 ports or from_port <= to_port, and protocol must be tcp, udp, icmp, or -1."
  }
}