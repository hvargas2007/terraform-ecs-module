resource "aws_ecs_cluster" "ecs" {
  name = var.name_prefix

  dynamic "setting" {
    for_each = var.uses_container_insights ? [1] : []

    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  tags = merge(var.project_tags, { Name = "${var.name_prefix}-cluster" })
}