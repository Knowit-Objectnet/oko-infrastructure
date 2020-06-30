provider "aws" {
  region = "eu-central-1"
}

module "ecs_service" {
  source = "../../modules/fargate-service"
  name   = "calendar-staging"
  vpc_id = var.vpc_id
  container_definitions = templatefile("task-definitions/calendar.json", {
    jdbc_address = "jdbc:postgresql://${aws_db_instance.calendar_db.endpoint}/calendar"
  })
  cluster_name                   = "ombruk-staging"
  container_name                 = "calendar"
  subnets                        = data.aws_subnet_ids.private_subnets.ids
  security_groups                = [aws_security_group.ecs_service.id]
  lb_arn                         = data.aws_lb.ecs_lb.arn
  lb_listener_port               = 8080
  container_port                 = 8080
  service_discovery_namespace_id = var.service_discovery_namespace_id
  tags                           = local.tags
  health_check_path              = "/"
  execution_role                 = aws_iam_role.ecs_execution_role.arn
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "calendar-ecs-execution-role-staging"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "calendar-ecs-execution-policy-staging"
  description = "Calendar ECS execution policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:*:*:parameter/calendar_db_staging_pass",
          "arn:aws:logs:eu-central-1:624304543898:log-group:calendar-staging:*",
          "arn:aws:ecr:eu-central-1:624304543898:repository/calendar"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "calendar-ecs-ecr-policy-staging"
  description = "Calendar ECS ECR pull policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ecs_ecr_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}


resource "aws_iam_role_policy_attachment" "execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}


resource "aws_security_group" "ecs_service" {
  name        = "calendar-ecs-service-staging"
  description = "Security group for calendar containers"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "calendar_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.6"
  instance_class         = "db.t3.micro"
  identifier             = "calendar-staging"
  name                   = "calendar"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_group
  username               = "REG_admin"
  password               = data.aws_ssm_parameter.calendar_db_creds.value
  parameter_group_name   = "default.postgres11"
  vpc_security_group_ids = [aws_security_group.calendar_db.id]
}

resource "aws_security_group" "calendar_db" {
  name        = "calendar-db-staging"
  description = "Security group for calendar database"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
