## VARIABLE GLOBAL
variable "name_prefix" {
  description = "[REQUERIDO] Prefijo del nombre de los recursos."
  type        = string
}

variable "aws_region" {
  description = "[REQUERIDO] Región de AWS."
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

variable "subnet_private" {
  description = "[REQUERIDO] Subnets privadas."
  type        = list(string)
}

## VARIABLE MODULOS

variable "ecs_cluster_id" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

variable "ecs_sg_id" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

variable "execution_role_arn" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

variable "task_role_arn" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

variable "tg_arn" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

## ECS SERVICE VARIABLE
variable "container_definitions" {
  description = "Definiciones del contenedor para ECS."
  type = list(object({
    name                = string
    cpu                 = number
    memory              = number
    container_port      = number
    desired_count       = number
    image_tag           = optional(string, "latest")
    external_image      = optional(string, "")
    root_directory_path = optional(string)
    environment = optional(list(object({
      name  = string
      value = string
    })), [])
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
    log_group_name    = string
    log_stream_prefix = string
  }))
}

variable "task_definition_name" {
  description = "Nombre personalizado para la task definition (opcional, por defecto usa el nombre del contenedor)"
  type        = string
  default     = ""
}

## ECR VARIABLE
variable "name_registry" {
  description = "[REQUERIDO] VPC ID."
  type        = string
}

variable "amount_of_ecr_images_to_keep" {
  description = "[REQUIRED] The number of images to keep in the ECR repository."
  type        = number
}

variable "scan_ecr_images_on_push" {
  description = "[REQUIRED] Whether to scan ECR images on push."
  type        = bool
}

variable "manage_task_definition" {
  description = "Whether Terraform should manage the task definition. Set to false to prevent Terraform from reverting pipeline deployments."
  type        = bool
  default     = true
}

variable "use_external_image" {
  description = "Whether to use an external image URL instead of the ECR repository"
  type        = bool
  default     = false
}

