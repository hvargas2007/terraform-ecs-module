
output "task_role_arn" {
  description = "ARN del rol para la ejecución de tareas ECS"
  value       = aws_iam_role.ecs_tasks_role.arn
}

output "execution_role_arn" {
  description = "ARN del rol para la ejecución de servicios ECS"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_tasks_role_policy_arn" {
  description = "ARN de la política adjunta al rol de tareas ECS"
  value       = aws_iam_role_policy_attachment.ecs_tasks_role.policy_arn
}

output "ecs_execution_role_policy_arn" {
  description = "ARN de la política adjunta al rol de ejecución ECS"
  value       = aws_iam_role_policy_attachment.ecs_execution_role.policy_arn
}

output "ecs_policy_name" {
  description = "Nombre de la política de ECS"
  value       = aws_iam_policy.ecs_policy.name
}

output "ecs_tasks_role_name" {
  description = "Nombre del rol para la ejecución de tareas ECS"
  value       = aws_iam_role.ecs_tasks_role.name
}

output "ecs_execution_role_name" {
  description = "Nombre del rol para la ejecución de servicios ECS"
  value       = aws_iam_role.ecs_execution_role.name
}
