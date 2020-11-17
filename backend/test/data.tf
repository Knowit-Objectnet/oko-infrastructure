data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id

  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

data "aws_lb" "ecs_lb" {
  name = "ombruk-ecs-test"
}

data "aws_ssm_parameter" "backend_db_creds" {
  name = "/test/backend/db_pass"
}

data "aws_ecs_cluster" "ombruk" {
  cluster_name = "ombruk-test"
}

data "aws_api_gateway_rest_api" "ombruk_api" {
  name = "ombruk-test"
}

data "aws_api_gateway_vpc_link" "ombruk_api" {
  name = "ombruk-test"
}
