provider "aws" {
  region = "eu-central-1"
}

module "ecs_service" {
  source = "../../modules/fargate-service"
  name   = "weight-reporting-prod"
  vpc_id = var.vpc_id
  container_definitions = templatefile("task-definitions/weight-reporting.json", {
    jdbc_address = "jdbc:postgresql://${aws_db_instance.weight_reporting_db.endpoint}/weight-reporting"
  })
  cluster_name                   = "ombruk-production"
  container_name                 = "weight-reporting"
  subnets                        = data.aws_subnet_ids.private_subnets.ids
  security_groups                = [aws_security_group.ecs_service.id]
  lb_arn                         = data.aws_lb.ecs_lb.arn
  lb_listener_port               = var.lb_port
  container_port                 = 8080
  service_discovery_namespace_id = var.service_discovery_namespace_id
  tags                           = local.tags
  health_check_path              = "/"
  execution_role                 = aws_iam_role.ecs_execution_role.arn
}

resource "aws_db_instance" "weight_reporting_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.6"
  instance_class         = "db.t3.micro"
  identifier             = "weight-reporting-production"
  name                   = "weightReporting"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_group
  username               = "REG_admin"
  password               = data.aws_ssm_parameter.weight_reporting_db_creds.value
  parameter_group_name   = "default.postgres11"
  vpc_security_group_ids = [aws_security_group.weight_reporting_db.id]
}
