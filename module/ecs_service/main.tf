################################################################################
# ECR Repository
################################################################################

resource "aws_ecr_repository" "ecr" {
  name                 = var.name_registry
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_ecr_images_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.amount_of_ecr_images_to_keep} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.amount_of_ecr_images_to_keep}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.container_definitions[0].log_group_name
  retention_in_days = 7
  tags              = var.project_tags
}

################################################################################
# ECS Task Definition and Service
################################################################################

resource "aws_ecs_task_definition" "task_def" {
  family                   = var.task_definition_name != "" ? var.task_definition_name : var.container_definitions[0].name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_definitions[0].cpu
  memory                   = var.container_definitions[0].memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = local.container_definitions
  tags                     = var.project_tags
}

# Service when managing task definition
resource "aws_ecs_service" "service_managed" {
  count                  = var.manage_task_definition ? 1 : 0
  name                   = var.container_definitions[0].name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.task_def.arn
  desired_count          = var.container_definitions[0].desired_count
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = var.subnet_private
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = var.container_definitions[0].name
    container_port   = var.container_definitions[0].container_port
  }

  tags = var.project_tags
}

# Service when NOT managing task definition
resource "aws_ecs_service" "service_unmanaged" {
  count                  = var.manage_task_definition ? 0 : 1
  name                   = var.container_definitions[0].name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.task_def.arn
  desired_count          = var.container_definitions[0].desired_count
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = var.subnet_private
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = var.container_definitions[0].name
    container_port   = var.container_definitions[0].container_port
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes = [task_definition]
  }
}