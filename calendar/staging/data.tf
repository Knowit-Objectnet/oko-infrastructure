data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id
}

data "aws_lb" "ecs_lb" {
  name = "ombruk-ecs-staging"
}

data "aws_security_group" "lb_sg" {
  name = "ombruk-ecs-lb-staging"
}

data "aws_ssm_parameter" "calendar_db_creds" {
  name = "calendar_db"
}