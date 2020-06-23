resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = var.name
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = var.name
  service_role_arn       = aws_iam_role.code_deploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = aws_ecs_service.service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_lb_listener.listener.arn}"]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}

resource "aws_iam_role" "code_deploy_role" {
  name = "${var.name}-code-deploy"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Principal = {
            Service = "codedeploy.amazonaws.com"
          }
          Effect = "Allow"
          Sid    = ""
        }
      ]
    }
  )

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "code-deploy-attachment" {
  role       = aws_iam_role.code_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}