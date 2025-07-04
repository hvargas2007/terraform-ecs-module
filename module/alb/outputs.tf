output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "Zone ID of the Application Load Balancer"
}