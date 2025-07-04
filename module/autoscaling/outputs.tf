output "autoscaling_target_id" {
  description = "ID del target de autoscaling"
  value       = aws_appautoscaling_target.service.id
}

output "cpu_scaling_policy_arn" {
  description = "ARN de la política de escalado por CPU"
  value       = aws_appautoscaling_policy.cpu_scaling.arn
}

output "memory_scaling_policy_arn" {
  description = "ARN de la política de escalado por memoria"
  value       = aws_appautoscaling_policy.memory_scaling.arn
}