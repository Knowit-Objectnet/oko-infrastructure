provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
  alias   = "certificate_region"
}

resource "aws_s3_bucket" "static" {
  bucket = "oslo-kommune-ombruk-frontend-test"
  acl    = "private"
  tags   = local.tags
}

resource "aws_s3_bucket" "redirect" {
  bucket = "oslo-kommune-ombruk-frontend-test-redirect"
  acl    = "private"
  tags   = local.tags

  website {
    redirect_all_requests_to = "https://test.oko.knowit.no"
  }
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_policy" "cloudfront_redirect" {
  bucket = aws_s3_bucket.redirect.id
  policy = data.aws_iam_policy_document.s3_policy_redirect.json
}

resource "aws_route53_record" "cloudfront" {
  name    = "test.oko.knowit.no"
  type    = "A"
  zone_id = data.aws_route53_zone.oko_zone.id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
  }
}

resource "aws_route53_record" "redirect" {
  name    = "www.test.oko.knowit.no"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.oko_zone.id
  ttl = 300
  records = [aws_cloudfront_distribution.frontend.domain_name]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Give cloudfront access to bucket"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = "frontend-test-bucket"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.redirect.website_endpoint
    origin_id   = "frontend-test-redirect-bucket"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["test.oko.knowit.no", "www.test.oko.knowit.no"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-test-bucket"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  tags = local.tags

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.id
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code              = "404"
    response_code           = "200"
    response_page_path      = "/index.html"
    error_caching_min_ttl   = 300
  }
}


resource "aws_acm_certificate" "cert" {
  provider          = aws.certificate_region
  domain_name       = "test.oko.knowit.no"
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type

  ttl     = 60
  zone_id = data.aws_route53_zone.oko_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.certificate_region
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

}