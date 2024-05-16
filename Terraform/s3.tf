resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.static_website_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "static_website_bucket" {
  bucket = aws_s3_bucket.static_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website_bucket" {
  bucket = aws_s3_bucket.static_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "static_website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_website_bucket,
    aws_s3_bucket_public_access_block.static_website_bucket,
  ]

  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "public-read"
}


data "aws_iam_policy_document" "allow_access_from_all_accounts" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_website_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
resource "aws_s3_bucket_website_configuration" "static_website_bucket" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }
}