terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial backend config: values supplied at init time via -backend-config=backend.hcl
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "iac-course-sample"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

module "artifacts_bucket" {
  source = "../modules/secure-bucket"

  name        = "iac-course-artifacts-${var.environment}-example"
  environment = var.environment
}

output "artifacts_bucket" {
  value = module.artifacts_bucket.bucket_id
}
