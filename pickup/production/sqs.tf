resource "aws_sqs_queue" "pickup_queue" {
  name                      = "pickup-production"
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 3

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.deadletter_queue.arn
    maxReceiveCount     = 5
  })

  tags = local.tags
}

resource "aws_sqs_queue" "deadletter_queue" {
  name                      = "pickup-deadletter-production"
  message_retention_seconds = 1209600


  tags = local.tags
}
