
resource "aws_iam_role" "ecs_execution_role" {
  name = "pickup-ecs-execution-role-production"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "pickup-ecs-execution-policy-production"
  description = "Pickup ECS execution policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:*:*:parameter/pickup_db_production_pass",
          "arn:aws:logs:eu-central-1:624304543898:log-group:pickup-production:*",
          "arn:aws:ecr:eu-central-1:624304543898:repository/pickup"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "pickup-ecs-ecr-policy-production"
  description = "Pickup ECS ECR pull policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "ecs_ecr_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}


resource "aws_iam_role_policy_attachment" "execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}