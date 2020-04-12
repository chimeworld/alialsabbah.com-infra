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

resource "aws_s3_bucket" "www-alialsabbah-site" {
  bucket = "www.alialsabbah.com"
  website {
    redirect_all_requests_to = "alialsabbah.com"
  }
}

resource "aws_s3_bucket_public_access_block" "block-alialsabbah-site" {
  bucket = aws_s3_bucket.alialsabbah-site.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "alialsabbah-cdn" {
  bucket = "alialsabbah-cdn"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "distribution" {
    origin {
    domain_name = aws_s3_bucket.alialsabbah-site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.alialsabbah-site.id

  }
  enabled = true
   logging_config {
    include_cookies = false
    bucket          = "alialsabbah-cdn.s3.amazonaws.com"
    prefix          = "cdn"
  }
    default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.alialsabbah-site.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
}
    viewer_certificate {
      acm_certificate_arn = "arn:aws:acm:us-east-1:422591206036:certificate/eaede853-bd64-47fc-87e6-09046038692b"
              minimum_protocol_version       = "TLSv1.1_2016"
              ssl_support_method             = "sni-only"
    }

    restrictions {
      geo_restriction{
      restriction_type = "none"
    }
    }

}

terraform {
  backend "s3" {
    bucket = "tfstate-ecpxdipaf8"
    key    = "alialsabbah.com/s3/terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "terraform-locker"
    encrypt        = true
  }
}
