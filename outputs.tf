output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ARN of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = module.alb.alb_zone_id
  description = "Zone ID of the Application Load Balancer"
}

output "ecs_cluster_id" {
  value       = module.ecs.ecs_cluster_id
  description = "ID of the ECS cluster"
}

output "ecs_cluster_name" {
  value       = module.ecs.ecs_cluster_name
  description = "Name of the ECS cluster"
}

output "alb_security_group_id" {
  value       = module.alb_security_group.ecs_sg_id
  description = "Security Group ID of the ALB"
}

output "ecs_security_group_id" {
  value       = module.security_groups.ecs_sg_id
  description = "Security Group ID of the ECS tasks"
}

# NLB Outputs (condicionales)
output "nlb_dns_name" {
  value       = var.alb_internal && var.deploy_nlb ? module.nlb[0].nlb_dns_name : null
  description = "DNS name of the Network Load Balancer (if deployed)"
}

output "nlb_arn" {
  value       = var.alb_internal && var.deploy_nlb ? module.nlb[0].nlb_arn : null
  description = "ARN of the Network Load Balancer (if deployed)"
}

output "nlb_zone_id" {
  value       = var.alb_internal && var.deploy_nlb ? module.nlb[0].nlb_zone_id : null
  description = "Zone ID of the Network Load Balancer (if deployed)"
}