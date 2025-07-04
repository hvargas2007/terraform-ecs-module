output "ecs_sg_id" {
  description = "ID del security group para ECS"
  value       = aws_security_group.ecs_sg.id
}

output "ecs_sg_name" {
  description = "Nombre del security group ECS"
  value       = aws_security_group.ecs_sg.name
}