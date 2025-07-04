# iam.tf

# ECS IAM Policy Document
data "aws_iam_policy_document" "ecs_policy_source" {
  statement {
    sid    = "CloudWatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSPolicy"
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:ListContainerInstances",
      "ecs:StopTask",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:ListTaskDefinitions",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMPolicy"
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3ConsoleAccess"
    effect = "Allow"
    actions = [
      "s3:GetAccountPublicAccessBlock",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketPublicAccessBlock",
      "s3:ListAccessPoints",
      "s3:ListAllMyBuckets",
      "s3:GetObject"
    ]
    resources = ["*"]
  }

  # Corrección aplicada aquí
  statement {
    sid    = "EfsAccess"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:Client*"
    ] # Coma eliminada
    resources = ["*"]
  }

  statement {
    sid    = "TaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ListObjectsInBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["*"]
  }

  statement {
    sid       = "AllObjectActions"
    effect    = "Allow"
    actions   = ["s3:*Object"]
    resources = ["*"]
  }

  # checkov:skip=CKV_AWS_356
  # checkov:skip=CKV_AWS_108
  # checkov:skip=CKV_AWS_111
}

# ECS IAM Role Policy Document
data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    sid    = "ECSAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ECS IAM Policy
resource "aws_iam_policy" "ecs_policy" {
  name   = "${var.name_prefix}-Policy-ecs"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_policy_source.json
  tags   = { Name = "${var.name_prefix}-Policy-ecs" }
}

resource "aws_iam_role" "ecs_tasks_role" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_role" {
  role       = aws_iam_role.ecs_tasks_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn

  # checkov:skip=CKV_AWS_2,CKV_AWS_310,CKV_AWS_174,CKV_AWS_305,CKV_AWS_86,CKV_AWS_51,CKV_AWS_136,CKV_AWS_163,CKV_AWS_51,CKV_AWS_249,CKV_AWS_23,CKV_AWS_333,CKV_AWS_111,CKV_AWS_356,CKV_AWS_108,CKV_AWS_158,CKV_AWS_7,CKV_AWS_354,CKV_AWS_353,CKV_AWS_226,CKV_AWS_161,CKV_AWS_118,CKV_AWS_129,CKV_AWS_192,CKV2_AWS_42,CKV2_AWS_30
}
