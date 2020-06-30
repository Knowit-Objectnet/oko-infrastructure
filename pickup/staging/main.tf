provider "aws" {
  region = "eu-central-1"
}

module "ecs_service" {
  source                         = "../../modules/fargate-service"
  name                           = "pickup-staging"
  vpc_id                         = var.vpc_id
  container_definitions          = file("task-definitions/pickup.json")
  cluster_name                   = "ombruk-staging"
  container_name                 = "pickup"
  subnets                        = data.aws_subnet_ids.private_subnets.ids
  security_groups                = [aws_security_group.ecs_service.id]
  lb_arn                         = data.aws_lb.ecs_lb.arn
  lb_listener_port               = 8081
  container_port                 = 8080
  service_discovery_namespace_id = var.service_discovery_namespace_id
  tags                           = local.tags
  health_check_path              = "/"
  execution_role                 = aws_iam_role.ecs_execution_role.arn
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "pickup-ecs-execution-role-staging"

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
  name        = "pickup-ecs-execution-policy-staging"
  description = "Pickup ECS execution policy"

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
          "arn:aws:ssm:*:*:parameter/pickup_db_staging_pass",
          "arn:aws:logs:eu-central-1:624304543898:log-group:pickup-staging:*",
          "arn:aws:ecr:eu-central-1:624304543898:repository/pickup"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "pickup-ecs-ecr-policy-staging"
  description = "Pickup ECS ECR pull policy"

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
  name        = "pickup-ecs-service-staging"
  description = "Security group for pickup containers"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [data.aws_security_group.lb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "pickup_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.6"
  instance_class         = "db.t3.micro"
  identifier             = "pickup-staging"
  name                   = "pickup"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_group
  username               = "REG_admin"
  password               = data.aws_ssm_parameter.pickup_db_creds.value
  parameter_group_name   = "default.postgres11"
  vpc_security_group_ids = [aws_security_group.pickup_db.id]
}

resource "aws_security_group" "pickup_db" {
  name        = "pickup-db-staging"
  description = "Security group for pickup database"
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
