data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc_id

  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

data "aws_lb" "ecs_lb_public" {
  name = "ombruk-ecs-public-test"
}

data "aws_security_group" "lb_sg_public" {
  name = "ombruk-ecs-lb-public-test"
}

data "aws_ssm_parameter" "keycloak_db_creds" {
  name = "keycloak_test_db_pass"
}

data "aws_ecs_cluster" "ombruk" {
  cluster_name = "ombruk-test"
}

data "aws_route53_zone" "oko_zone" {
  name         = "oko.knowit.no"
  private_zone = false
}

data "aws_acm_certificate" "wildcard" {
  domain   = "*.test.oko.knowit.no"
  statuses = ["ISSUED"]
}