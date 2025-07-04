resource "aws_lb_listener" "http" {
  load_balancer_arn = var.alb_arn
  port              = "80"
  protocol          = "HTTP"
  tags              = var.project_tags

  default_action {
    type = var.https_enabled ? "redirect" : "fixed-response"

    dynamic "redirect" {
      for_each = var.https_enabled ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "fixed_response" {
      for_each = var.https_enabled ? [] : [1]
      content {
        content_type = "text/plain"
        message_body = "No target group configured"
        status_code  = "503"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.https_enabled ? 1 : 0

  load_balancer_arn = var.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  ssl_policy        = var.ssl_policy
  tags              = var.project_tags

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No target group configured"
      status_code  = "503"
    }
  }
}