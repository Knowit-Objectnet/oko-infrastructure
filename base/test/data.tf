data "aws_route53_zone" "oko_zone" {
  name         = "oko.knowit.no"
  private_zone = false
}
