output "ecr_repository_url" {
  value       = aws_ecr_repository.ecr.repository_url
  description = "URL of the ECR repository"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.ecr.arn
  description = "ARN of the ECR repository"
}

output "ecs_service_name" {
  value       = var.manage_task_definition ? aws_ecs_service.service_managed[0].name : aws_ecs_service.service_unmanaged[0].name
  description = "Name of the ECS service"
}

output "ecs_service_id" {
  value       = var.manage_task_definition ? aws_ecs_service.service_managed[0].id : aws_ecs_service.service_unmanaged[0].id
  description = "ID of the ECS service"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.task_def.arn
  description = "ARN of the task definition"
}

output "service_name" {
  value       = var.manage_task_definition ? aws_ecs_service.service_managed[0].name : aws_ecs_service.service_unmanaged[0].name
  description = "Name of the ECS service for autoscaling"
}