variable "name_prefix" {
  description = "Prefix for the names of resources related to inbound VPC."
  type        = string
}

variable "transit_id" {
  description = "Transit Gateway ID (required only when use_transit_gateway is true)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the outbound VPC."
  type        = string
}

variable "PrivateSubnet" {
  description = "List of maps containing the key values for creating the CIDR using the cidrsubnets function, along with the name and index number for the availability zone of outbound private subnet."
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "PrivateSubnetDb" {
  description = "List of maps containing the key values for creating the CIDR using the cidrsubnets function, along with the name and index number for the availability zone of outbound private subnet."
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

#Variables de etiquetas del proyecto
variable "project-tags" {
  type = map(string)
  default = {
  }
}

# Variables for conditional resource creation
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
  description = "Whether to create NAT Gateways for private subnets"
  type        = bool
  default     = false
}

variable "use_transit_gateway" {
  description = "Whether to use Transit Gateway for routing (if false and NAT is enabled, will use NAT Gateway)"
  type        = bool
  default     = true
}

variable "PublicSubnet" {
  description = "List of public subnets configuration (only used when create_public_subnets is true)"
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default = []
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

