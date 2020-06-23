
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${var.name}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_up_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "${var.name}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.scale_down_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.name
  retention_in_days = 30

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = var.name
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
