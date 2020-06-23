resource "aws_appautoscaling_target" "target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.name}-scale-up"
  service_namespace  = aws_appautoscaling_target.target.service_namespace
  resource_id        = aws_appautoscaling_target.target.resource_id
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.name}-scale-down"
  service_namespace  = aws_appautoscaling_target.target.service_namespace
  resource_id        = aws_appautoscaling_target.target.resource_id
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
}