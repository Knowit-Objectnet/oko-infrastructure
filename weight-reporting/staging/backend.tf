terraform {
  backend "s3" {
    bucket         = "oslo-kommune-ombruk-terraform"
    key            = "weight-reporting/staging"
    profile        = "default"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
  }
}