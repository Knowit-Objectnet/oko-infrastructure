provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "code-deploy-appspec" {
  bucket = "oslo-kommune-ombruk-codedeploy"
  acl    = "private"
  tags   = local.tags
}