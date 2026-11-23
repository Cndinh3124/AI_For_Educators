# Intentionally NON-COMPLIANT configuration used to generate a policy-test fixture.
# Never apply this. Each block violates exactly one guardrail (see comments).
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = "ap-southeast-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# Violation: prod bucket without access logging; missing Project tag.
resource "aws_s3_bucket" "reports" {
  bucket = "iac-course-reports-prod-example"
  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# Violation: public access not fully blocked.
resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Violation: SSE-S3 instead of SSE-KMS.
resource "aws_s3_bucket_server_side_encryption_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Violation: wildcard IAM.
resource "aws_iam_policy" "ci_admin" {
  name = "ci-admin-example"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "*", Resource = "*" },
      { Effect = "Allow", Action = ["s3:*"], Resource = "*" },
    ]
  })
}
