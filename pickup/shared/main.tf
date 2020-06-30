provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "pickup" {
  name    = "pickup"
}

resource "aws_api_gateway_rest_api" "pickup" {
  name        = "pickup"
  description = "Oslo kommune pickup microservice api gateway."
}
