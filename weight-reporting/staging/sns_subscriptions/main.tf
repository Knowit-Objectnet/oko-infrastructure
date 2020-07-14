provider "aws" {
    region = "eu-central-1"
}

resource "aws_sns_topic_subscription" "subscriptions" {
    for_each = var.topics
    topic_arn = data.aws_sns_topic.topics[each.key].arn
    protocol = "sqs"
    endpoint = data.aws_sqs_queue.weight_reporting.arn
    raw_message_delivery = true
}

resource "aws_sqs_queue_policy" "test" {
    queue_url = data.aws_sqs_queue.weight_reporting.url

    policy = templatefile("policies/queue_policy.json.tmpl", {
        queue_arn = data.aws_sqs_queue.weight_reporting.arn
        topic_arns = jsonencode([for topic in data.aws_sns_topic.topics: topic.arn])
        policy_id = "${data.aws_sqs_queue.weight_reporting.name}-policy"
    })
}
