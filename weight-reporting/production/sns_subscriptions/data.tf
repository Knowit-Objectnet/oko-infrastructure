data "aws_sns_topic" "topics" {
  for_each = var.topics
  name = each.value
}

data "aws_sqs_queue" weight_reporting {
  name = "weight-reporting-production"
}