provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "s3_bucket_react_app" {
  bucket = "oslo-kommune-ombruk-frontend"
  acl    = "public-read"

  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = local.tags
}