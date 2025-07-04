## GLOBAL VARIABLES
variable "project_tags" {
  description = "[REQUIRED] Project tags for resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "[REQUIRED] VPC ID"
  type        = string
}

variable "name_prefix" {
  description = "[REQUIRED] Prefix for resource names"
  type        = string
}

## TARGET GROUP VARIABLES
variable "service_name" {
  description = "[REQUIRED] Name of the service"
  type        = string
}

variable "container_port" {
  description = "[REQUIRED] Container port"
  type        = number
}

## LISTENER RULE VARIABLES
variable "listener_arn" {
  description = "[REQUIRED] ARN of the ALB listener"
  type        = string
}

variable "rule_priority" {
  description = "[REQUIRED] Priority for the listener rule"
  type        = number
}

variable "path_patterns" {
  description = "Path patterns for routing"
  type        = list(string)
  default     = []
}

variable "host_headers" {
  description = "Host headers for routing"
  type        = list(string)
  default     = []
}

## HEALTH CHECK VARIABLES
variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "health_check_matcher" {
  description = "Health check response codes"
  type        = string
  default     = "200"
}