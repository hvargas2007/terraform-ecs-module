variable "service_name" {
  description = "Nombre del servicio ECS"
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
}

variable "min_capacity" {
  description = "Número mínimo de tareas"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Número máximo de tareas"
  type        = number
  default     = 4
}

variable "cpu_target_value" {
  description = "Valor objetivo de CPU para el escalado"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Valor objetivo de memoria para el escalado"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Cooldown en segundos para reducir capacidad"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown en segundos para aumentar capacidad"
  type        = number
  default     = 60
}