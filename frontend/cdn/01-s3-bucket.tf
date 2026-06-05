# Unique bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 BUCKET (PRIVATE)
resource "aws_s3_bucket" "frontend" {
  bucket = "ecommerce-frontend-${random_id.suffix.hex}"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "ecommerce-frontend"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
