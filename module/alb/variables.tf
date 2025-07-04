variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_tags" {
  description = "Project tags for resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "List of subnet IDs for the ALB (must be in at least 2 AZs)"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB should be internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}