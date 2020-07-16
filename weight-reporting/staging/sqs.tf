resource "aws_sqs_queue" "weight-reporting_queue" {
  name                      = "weight-reporting-staging"
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 3

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 5
  })

  tags = local.tags
}

resource "aws_sqs_queue" "deadletter_queue" {
  name                      = "weight-reporting-deadletter-staging"
  message_retention_seconds = 1209600


  tags = local.tags
}
