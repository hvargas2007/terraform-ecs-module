## VARIABLE GLOBAL
variable "name_prefix" {
  description = "[REQUERIDO] Prefijo del nombre de los recursos."
  type        = string
}

variable "project_tags" {
  description = "[REQUERIDO] Project tags para los recursos."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

## SECURITY GROUP VARIABLES
variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
}

variable "egress_rules" {
  description = "Egress rules for the security group"
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
}