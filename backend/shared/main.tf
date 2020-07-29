provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "backend" {
  name = "backend"
}