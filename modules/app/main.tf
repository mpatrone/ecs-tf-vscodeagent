# IAM Roles and Policies
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "ecsTaskExecutionRoleTF"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role" "ecs_task" {
  name               = "ecsTaskRoleTF"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Add ECS Exec permissions to task role
resource "aws_iam_role_policy" "ecs_exec_policy" {
  name = "${var.environment}-ecs-exec-policy"
  role = aws_iam_role.ecs_task.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security Groups
resource "aws_security_group" "public_task" {
  name_prefix = "tf-sg-public-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "tf-sg-public"
    }
  )
}

resource "aws_security_group" "private_task" {
  name_prefix = "tf-sg-private-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "tf-sg-private"
    }
  )
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "task1" {
  name              = "/ecs/tf-svc1"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "task2" {
  name              = "/ecs/tf-svc2"
  retention_in_days = 30
}

# Service Connect Namespace
resource "aws_service_discovery_http_namespace" "tf_ns" {
  name = "tf-ns"
}

# Task Definitions
resource "aws_ecs_task_definition" "task1" {
  family                   = "tf-td1"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = 2048
  memory                  = 4096
  execution_role_arn      = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name         = "tf-task1"
      image        = "ubuntu/nginx"
      cpu         = 2048
      memory      = 4096
      essential   = true
      
      portMappings = [
        {
          name          = "http"
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.task1.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "tf-svc1"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "task2" {
  family                   = "tf-td2"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = 2048
  memory                  = 4096
  execution_role_arn      = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name         = "tf-task2"
      image        = "ubuntu/nginx"
      cpu         = 2048
      memory      = 4096
      essential   = true
      
      portMappings = [
        {
          name          = "http"
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.task2.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "tf-svc2"
        }
      }
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "service1" {
  name            = "tf-svc1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.task1.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [aws_security_group.public_task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "tf-task1"
    container_port   = 80
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.tf_ns.arn
    service {
      port_name      = "http"
      discovery_name = "tf-svc1"
      client_alias {
        port     = 80
        dns_name = "tf-svc1"
      }
    }
  }
}

resource "aws_ecs_service" "service2" {
  name            = "tf-svc2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.task2.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.private_task.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.tf_ns.arn
    service {
      port_name      = "http"
      discovery_name = "tf-svc2"
      client_alias {
        port     = 80
        dns_name = "tf-svc2"
      }
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Data sources
data "aws_region" "current" {}