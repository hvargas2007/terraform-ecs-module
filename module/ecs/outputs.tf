# Output para el ID del ECS Cluster
output "ecs_cluster_id" {
  value       = aws_ecs_cluster.ecs.id
  description = "El ID del ECS Cluster"
}

# Output para el nombre del ECS Cluster
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs.name
  description = "El nombre del ECS Cluster"
}

# Output para el ARN del ECS Cluster
output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.ecs.arn
  description = "El ARN del ECS Cluster"
}