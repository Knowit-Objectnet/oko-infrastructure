data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id

  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

data "aws_lb" "ecs_lb" {
  name = "ombruk-ecs-staging"
}

data "aws_ssm_parameter" "calendar_db_creds" {
  name = "/staging/calendar/db_pass"
}

data "aws_ecs_cluster" "ombruk" {
  cluster_name = "ombruk-staging"
}

data "aws_mq_broker" "ombruk" {
  broker_name = "ombruk-staging"
}
