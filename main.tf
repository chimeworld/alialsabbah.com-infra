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
resource "aws_s3_bucket" "alialsabbah-cdn" {
  bucket = "alialsabbah"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}
