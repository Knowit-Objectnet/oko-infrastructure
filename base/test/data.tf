data "aws_route53_zone" "oko_zone" {
  name         = "oko.knowit.no"
  private_zone = false
}

/*
data "aws_ssm_parameter" "mq_admin_pass" {
  name = "/test/mq/admin_pass"
}

data "aws_ssm_parameter" "mq_calendar_pass" {
  name = "/test/mq/calendar_pass"
}

data "aws_ssm_parameter" "mq_pickup_pass" {
  name = "/test/mq/pickup_pass"
}
*/