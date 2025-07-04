resource "aws_lb" "alb" {
  name               = "${var.name_prefix}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(var.project_tags, {
    Name = "${var.name_prefix}"
  })
}