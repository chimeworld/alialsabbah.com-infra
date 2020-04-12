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
