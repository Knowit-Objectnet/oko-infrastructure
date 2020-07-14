resource "aws_sqs_queue" "pickup_queue" {
  name                      = "pickup-staging"
  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 5
  })

  tags = local.tags
}

resource "aws_sqs_queue" "deadletter_queue" {
  name                      = "pickup-deadletter-staging"
  message_retention_seconds = 1209600


  tags = local.tags
}
