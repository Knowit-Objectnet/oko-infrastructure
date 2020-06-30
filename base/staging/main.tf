provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.39.0"

  name = "ombruk-vpc-staging"

  cidr = "10.0.0.0/16"

  azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.tags
}


resource "aws_ecs_cluster" "cluster" {
  name               = "ombruk-staging"
  capacity_providers = ["FARGATE"]
  tags               = local.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = "staging.ombruk.oslo.kommune"
  description = "namespace for ombruk in oslo municipality"
  vpc         = module.vpc.vpc_id
}

resource "aws_lb" "ecs" {
  name                       = "ombruk-ecs-staging"
  load_balancer_type         = "network"
  internal                   = true
  drop_invalid_header_fields = false
  enable_http2               = false
  idle_timeout               = 60
  subnets                    = module.vpc.private_subnets

  tags = local.tags
}

resource "aws_lb" "ecs_public" {
  name            = "ombruk-ecs-public-staging"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.ecs_lb_public.id]
  tags            = local.tags
}

resource "aws_security_group" "ecs_lb_public" {
  name        = "ombruk-ecs-lb-public-staging"
  description = "Controls access to the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.staging.oko.knowit.no"
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.oko_zone.zone_id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_api_gateway_vpc_link" "staging_vpc" {
  name        = "ombruk-staging"
  description = "Link ombruk API gateway to ombruk staging vpc"
  target_arns = [aws_lb.ecs.arn]
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.staging.oko.knowit.no"
  regional_certificate_arn = aws_acm_certificate.cert.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.oko_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}
