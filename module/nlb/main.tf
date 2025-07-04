resource "aws_lb" "nlb" {
  name                             = "${var.name_prefix}"
  internal                         = var.internal
  load_balancer_type               = "network"
  subnets                          = var.subnet_ids
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.project_tags,
    {
      Name = "${var.name_prefix}"
    }
  )
}

resource "aws_lb_target_group" "nlb_to_alb" {
  name        = var.target_group_name != "" ? var.target_group_name : "${var.name_prefix}-tg"
  port        = var.certificate_arn != "" ? 443 : 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200-599"
    path                = "/"
  }

  deregistration_delay = 30

  tags = merge(
    var.project_tags,
    {
      Name = var.target_group_name != "" ? var.target_group_name : "${var.name_prefix}-tg"
    }
  )
}

resource "aws_lb_target_group_attachment" "nlb_to_alb" {
  target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  target_id        = var.alb_arn
  port             = var.certificate_arn != "" ? 443 : 80

  depends_on = [var.alb_listener_arns]
}

resource "aws_lb_listener" "nlb_http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  }
}

resource "aws_lb_listener" "nlb_https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb.arn
  }
}