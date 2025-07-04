resource "aws_ssm_parameter" "parameter" {
  for_each = var.parameters

  name        = "${each.key}"
  description = "SSM Parameter for ${var.service_name}: ${each.key}"
  type        = "SecureString"
  value       = each.value

  tags = merge(
    var.project_tags,
    {
      Service     = var.service_name
      Environment = var.environment
    }
  )
}