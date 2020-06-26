data "aws_route53_zone" "ok_zone" {
  name         = "oko.knowit.no"
  private_zone = false
}