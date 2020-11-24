resource "aws_lb_target_group" "blue" {
  name        = "${var.name}-blue"
  port        = var.container_port
  protocol    = "TCP" // HTTP for keycloak, TCP for backend
  vpc_id      = var.vpc_id
  target_type = "ip"
  /*
  stickiness {
    enabled = false
    type    = "source_ip" // lb_cookie
  }
  */

  health_check {
    path = var.health_check_path
  }

  tags = var.tags
}

resource "aws_lb_target_group" "green" {
  count       = var.enable_code_deploy ? 1 : 0
  name        = "${var.name}-green"
  port        = var.container_port
  protocol    = "TCP" // HTTP for keycloak, TCP for backend
  vpc_id      = var.vpc_id
  target_type = "ip"
  /*
  stickiness {
    enabled = false
    type    = "source_ip" // lb_cookie
  }
  */

  health_check {
    path = var.health_check_path
  }

  tags = var.tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.lb_arn
  port              = var.lb_listener_port
  protocol          = "TCP" // HTTP for keycloak, TCP for backend

  dynamic "default_action" {
    for_each = var.lb_listener_certificate_arn != null ? toset([1]) : toset([])
    content {
      type = "redirect"

      redirect {
        port        = var.lb_listener_ssl_port
        protocol    = "TLS" // HTTPS for keycloak, TLS for backend
        status_code = "HTTP_301"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn
    ]
  }

  dynamic "default_action" {
    for_each = var.lb_listener_certificate_arn == null ? toset([1]) : toset([])
    content {
      target_group_arn = aws_lb_target_group.blue.arn
      type             = "forward"
    }
  }
}

resource "aws_lb_listener" "listener_https" {
  count             = var.lb_listener_certificate_arn != null ? 1 : 0
  load_balancer_arn = var.lb_arn
  port              = var.lb_listener_ssl_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.lb_listener_certificate_arn
  lifecycle {
    ignore_changes = [
      default_action[0].target_group_arn
    ]
  }

  default_action {
    target_group_arn = aws_lb_target_group.blue.arn
    type             = "forward"
  }
}
