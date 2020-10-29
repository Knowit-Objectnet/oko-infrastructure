provider "aws" {
  region = "eu-central-1"
}

module "ecs_service" {
  source = "../../modules/fargate-service"
  name   = "keycloak-test"
  vpc_id = var.vpc_id
  container_definitions = templatefile("task-definitions/keycloak.json", {
    db_address = aws_db_instance.keycloak_db.endpoint
  })
  lb_listener_certificate_arn    = data.aws_acm_certificate.wildcard.arn
  cluster_name                   = "ombruk-test"
  container_name                 = "keycloak"
  subnets                        = data.aws_subnet_ids.private_subnets.ids
  security_groups                = [aws_security_group.ecs_service.id]
  lb_arn                         = data.aws_lb.ecs_lb_public.arn
  container_port                 = 8080
  lb_listener_ssl_port           = 8443
  lb_listener_port               = 8080
  health_check_path              = "/auth/"
  service_discovery_namespace_id = var.service_discovery_namespace_id
  enable_code_deploy             = false
  execution_role                 = aws_iam_role.ecs_execution_role.arn
  tags                           = local.tags
  cpu                            = 512
  memory                         = 2048
  desired_count                  = 1
  max_capacity                   = 1
  min_capacity                   = 1
  health_check_grace_period      = 300
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "keycloak-ecs-execution-role-test"

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
  name        = "keycloak-ecs-execution-policy-test"
  description = "Keycloak policy to get ssm secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:*:*:parameter/keycloak_test_admin_pass",
          "arn:aws:ssm:*:*:parameter/keycloak_test_db_pass",
          "arn:aws:logs:eu-central-1:624304543898:log-group:keycloak-test:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}


resource "aws_db_instance" "keycloak_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.6"
  instance_class         = "db.t3.micro"
  identifier             = "keycloak-test"
  name                   = "keycloak"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_group
  username               = "REG_admin"
  password               = data.aws_ssm_parameter.keycloak_db_creds.value
  parameter_group_name   = "default.postgres11"
  vpc_security_group_ids = [aws_security_group.keycloak_db.id]
}


resource "aws_security_group" "keycloak_db" {
  name        = "keycloak-db-test"
  description = "Security group for keycloak database"
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

resource "aws_security_group" "ecs_service" {
  name        = "keycloak-ecs-service-staging"
  description = "Security group for keycloak containers"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp" // "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [data.aws_security_group.lb_sg_public.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "keycloak_record" {
  zone_id = data.aws_route53_zone.oko_zone.zone_id
  name    = "keycloak.test.oko.knowit.no"
  type    = "A"

  alias {
    name                   = data.aws_lb.ecs_lb_public.dns_name
    zone_id                = data.aws_lb.ecs_lb_public.zone_id
    evaluate_target_health = false
  }

}