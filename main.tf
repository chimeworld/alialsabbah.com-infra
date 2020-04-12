provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "alialsabbah-site" {
  bucket = "alialsabbah.com"
  policy = file("policy.json")
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "block-alialsabbah-site" {
  bucket                  = aws_s3_bucket.alialsabbah-site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "www-alialsabbah-site" {
  bucket = "www.alialsabbah.com"
  website {
    redirect_all_requests_to = "alialsabbah.com"
  }
}

resource "aws_s3_bucket_public_access_block" "block-www-site" {
  bucket                  = aws_s3_bucket.www-alialsabbah-site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "alialsabbah-cdn" {
  bucket = "alialsabbah-cdn"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "block-cdn" {
  bucket                  = aws_s3_bucket.alialsabbah-cdn.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.alialsabbah-site.website_endpoint 
    origin_id   = "S3-${aws_s3_bucket.alialsabbah-site.id}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  logging_config {
    bucket          = aws_s3_bucket.alialsabbah-cdn.bucket_domain_name
    include_cookies = false
    prefix          = "cdn/"
  }

  aliases = [
    aws_s3_bucket.alialsabbah-site.id,
    aws_s3_bucket.www-alialsabbah-site.id,
  ]
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "S3-${aws_s3_bucket.alialsabbah-site.id}"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }


  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:422591206036:certificate/eaede853-bd64-47fc-87e6-09046038692b"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }

}

terraform {
  backend "s3" {
    bucket         = "tfstate-ecpxdipaf8"
    key            = "alialsabbah.com/s3/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locker"
    encrypt        = true
  }
}
