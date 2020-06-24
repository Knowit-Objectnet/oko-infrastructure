resource "aws_lb_target_group" "blue" {
  name        = "${var.name}-blue"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }

  tags = var.tags
}

resource "aws_lb_target_group" "green" {
  count       = var.enable_code_deploy ? 1 : 0
  name        = "${var.name}-green"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }

  tags = var.tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.lb_arn
  port              = var.lb_listener_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.blue.arn
    type             = "forward"
  }
}
