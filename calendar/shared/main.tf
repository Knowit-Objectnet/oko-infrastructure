provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "calendar" {
  name = "calendar"
}

resource "aws_api_gateway_rest_api" "calendar" {
  name        = "calendar"
  description = "Oslo kommune calendar microservice api gateway."
}
