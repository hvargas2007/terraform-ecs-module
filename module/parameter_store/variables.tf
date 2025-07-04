variable "service_name" {
  description = "Nombre del servicio (api, frontend, etc)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "parameters" {
  description = "Mapa de parámetros a crear en Parameter Store"
  type        = map(string)
  default     = {}
}

variable "project_tags" {
  description = "Tags del proyecto"
  type        = map(string)
  default     = {}
}