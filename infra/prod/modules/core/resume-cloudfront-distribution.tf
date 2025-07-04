
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
  default_root_object = "index.html"
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
