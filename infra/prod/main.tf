terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }
  backend "s3" {
    bucket         = "resume-gagelara-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_budgets_budget" "account_budget" {
  name              = "account_budget"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "4"
  limit_unit        = "USD"
  time_period_start = "2025-06-25_00:00"
}

resource "aws_s3_bucket" "resume_gagelara" {
  bucket = "resume.gagelara"
}

resource "aws_dynamodb_table" "resume_gagelara_dynodb" {
  name         = "resume_gagelara_dynodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_cloudfront_origin_access_control" "resume_gagelara_oac" {
  name                              = "resume_gagelara_oac"
  description                       = "OAC for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "resume_gagelara_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_All"
  default_root_object = "public/index.html"
  wait_for_deployment = true
  retain_on_delete    = false

  aliases = [
    "gagelara.com",
    "www.gagelara.com",
  ]

  origin {
    domain_name              = "resume.gagelara.s3.us-east-2.amazonaws.com"
    origin_id                = "resume.gagelara.s3.us-east-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_gagelara_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "resume.gagelara.s3.us-east-2.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress    = true
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:663970204219:certificate/fbf8f200-eda5-418f-b084-a8b5298722ec"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  tags = {}
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_gagelara.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.resume_gagelara_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cf_oac" {
  bucket = aws_s3_bucket.resume_gagelara.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
