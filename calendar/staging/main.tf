provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecs_cluster" "calendar" {
  name               = "calendar-staging"
  capacity_providers = ["FARGATE"]
  tags               = local.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "ecs_service" {
  source                         = "../../modules/fargate-service"
  name                           = "calendar-staging"
  vpc_id                         = var.vpc_id
  container_definitions          = file("task-definitions/calendar.json")
  cluster_name                   = aws_ecs_cluster.calendar.name
  container_name                 = "calendar"
  subnets                        = data.aws_subnet_ids.private_subnets.ids
  lb_arn                         = data.aws_lb.ecs_lb.arn
  lb_listener_port               = 80
  service_discovery_namespace_id = var.service_discovery_namespace_id
  tags                           = local.tags
}

resource "aws_security_group" "ecs_service" {
  name        = "calendar-ecs-service-staging"
  description = "Security group for calendar containers"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [data.aws_security_group.lb_sg.id]
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
