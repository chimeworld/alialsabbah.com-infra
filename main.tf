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
  bucket = "alialsabbah"
  acl    = "private"

  website {
    index_document = "index.html"
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
