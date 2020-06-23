resource "aws_ecs_task_definition" "task_definition" {
  family                = var.name
  container_definitions = var.container_definitions

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"

  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = data.aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.task_definition.id


  desired_count = var.desired_count
  lifecycle {
    ignore_changes = [desired_count, load_balancer, network_configuration, task_definition]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service.arn
  }

  propagate_tags = "SERVICE"
}

resource "aws_service_discovery_service" "service" {
  name = var.name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}


