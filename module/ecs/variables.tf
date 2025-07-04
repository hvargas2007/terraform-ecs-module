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


## CLUSTER ECS VARIABLE
variable "uses_container_insights" {
  description = "Habilitar Container Insights. Valor por defecto: false."
  type        = bool
  default     = false
}
