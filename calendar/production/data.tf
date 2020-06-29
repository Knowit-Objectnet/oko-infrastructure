data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id

  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

data "aws_lb" "ecs_lb" {
  name = "ombruk-ecs-production"
}

data "aws_security_group" "lb_sg" {
  name = "ombruk-ecs-lb-production"
}

data "aws_ssm_parameter" "calendar_db_creds" {
  name = "calendar_db_production"
}

data "aws_ecs_cluster" "ombruk" {
  cluster_name = "ombruk-production"
}