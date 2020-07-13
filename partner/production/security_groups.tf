resource "aws_security_group" "ecs_service" {
  name        = "partner-ecs-service-production"
  description = "Security group for partner containers"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "partner_db" {
  name        = "partner-db-production"
  description = "Security group for partner database"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
