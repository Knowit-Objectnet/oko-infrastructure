provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "weight_reporting" {
  name = "weight-reporting"
}

