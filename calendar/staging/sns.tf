resource "aws_sns_topic" "calendar_updates" {
  name = "calendar-updates-staging"

  tags = local.tags
}
