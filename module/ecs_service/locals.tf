locals {
  container_definitions = jsonencode([
    {
      name      = var.container_definitions[0].name
      image     = var.use_external_image && var.container_definitions[0].external_image != "" ? var.container_definitions[0].external_image : "${aws_ecr_repository.ecr.repository_url}:${var.container_definitions[0].image_tag}"
      cpu       = var.container_definitions[0].cpu
      memory    = var.container_definitions[0].memory
      essential = true

      portMappings = [
        {
          containerPort = var.container_definitions[0].container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for env_var in var.container_definitions[0].environment : {
          name  = env_var.name
          value = env_var.value
        }
      ]

      secrets = [
        for secret in var.container_definitions[0].secrets : {
          name      = secret.name
          valueFrom = secret.valueFrom
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.container_definitions[0].log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.container_definitions[0].log_stream_prefix
        }
      }
    }
  ])
}
