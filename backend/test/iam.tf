resource "aws_iam_role" "ecs_execution_role" {
  name = "backend-ecs-execution-role-test"

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
  name        = "backend-ecs-execution-policy-test"
  description = "backend ECS execution policy"

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
          "arn:aws:ssm:*:*:parameter/test/backend/*",
          "arn:aws:logs:eu-central-1:624304543898:log-group:backend-test:*",
          "arn:aws:ecr:eu-central-1:624304543898:repository/backend-ecr"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "backend-ecs-ecr-policy-test"
  description = "backend ECS ECR pull policy"

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

resource "aws_iam_user" "notification" {
  name = "notification-test"
}

resource "aws_iam_access_key" "notification" {
  user    = aws_iam_user.notification.name
}

resource "aws_iam_user_policy" "notification_ro" {
  name = "backend-notification-execution-role-test"
  user = aws_iam_user.notification.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ses:*"
        ],
        "Resource": "*"
    },
    {
        "Action": [
            "sns:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction"
        ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}