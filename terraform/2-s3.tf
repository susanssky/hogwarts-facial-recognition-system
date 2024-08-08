
########## first bucket
resource "aws_s3_bucket" "s3_hogwarts_registerd" {
  bucket        = "${local.project_name}-registered-s3"
  force_destroy = true
  tags = {
    Name = "${local.project_name}-s3"
  }
}

# add trigger with lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_hogwarts_registerd.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.registered.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

# upload the images
resource "aws_s3_object" "s3-object" {
  depends_on = [aws_s3_bucket_notification.bucket_notification]
  bucket     = aws_s3_bucket.s3_hogwarts_registerd.id
  for_each = {
    for f in fileset("./Hogwarts/", "**/*") : f => f
    if !endswith(f, ".DS_Store")
  }
  key          = each.value
  source       = "./Hogwarts/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"

  }
}

########## second bucket
resource "aws_s3_bucket" "s3_hogwarts_visitor" {
  bucket        = "${local.project_name}-visitor-s3"
  force_destroy = true

  tags = {
    Name = "${local.project_name}-s3"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.s3_hogwarts_visitor.id

  rule {
    id = "auto-delete-after-1-day"
    expiration {
      days = 1
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}
