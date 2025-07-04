output "parameter_arns" {
  description = "ARNs de los parámetros creados"
  value       = { for k, v in aws_ssm_parameter.parameter : k => v.arn }
}

output "parameter_names" {
  description = "Nombres completos de los parámetros en SSM"
  value       = { for k, v in aws_ssm_parameter.parameter : k => v.name }
}