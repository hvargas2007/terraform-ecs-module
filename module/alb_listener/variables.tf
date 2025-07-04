variable "alb_arn" {
  description = "ARN of the ALB"
  type        = string
}

variable "https_enabled" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "project_tags" {
  description = "Project tags"
  type        = map(string)
  default     = {}
}