output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.tg.name
}


