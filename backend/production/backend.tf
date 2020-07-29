terraform {
  backend "s3" {
    bucket         = "oslo-kommune-ombruk-terraform"
    key            = "backend/production"
    profile        = "default"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
  }
}