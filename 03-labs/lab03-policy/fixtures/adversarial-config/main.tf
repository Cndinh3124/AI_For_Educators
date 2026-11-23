# Adversarial fixture: two buckets in the same module, only ONE has a public access block.
# A naive "same module has a PAB" check lets aws_s3_bucket.unprotected slip through.
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
  default_tags {
    tags = { Project = "iac-course-sample", ManagedBy = "terraform", Environment = "dev" }
  }
}

resource "aws_s3_bucket" "protected" {
  bucket = "iac-course-protected-example"
}

resource "aws_s3_bucket_public_access_block" "protected" {
  bucket                  = aws_s3_bucket.protected.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "unprotected" {
  bucket = "iac-course-unprotected-example"
}
