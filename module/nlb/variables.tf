variable "name_prefix" {
  description = "Prefix to be used on all resources for identification"
  type        = string
}

variable "target_group_name" {
  description = "Name for the NLB target group (optional, defaults to name_prefix-tg)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the NLB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for the NLB (minimum 2 in different AZs)"
  type        = list(string)
}

variable "alb_arn" {
  description = "ARN of the internal ALB to target"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the NLB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (optional)"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL/TLS policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "internal" {
  description = "Whether the ALB should be internal"
  type        = bool
  default     = false
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alb_listener_arns" {
  description = "List of ALB listener ARNs to depend on"
  type        = list(string)
  default     = []
}