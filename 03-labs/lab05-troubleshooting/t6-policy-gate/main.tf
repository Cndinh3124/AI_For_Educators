# Ticket: "Policy gate blocks my PR with 'missing required tags', but the module sets tags!"
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

module "artifacts_bucket" {
  source = "../../modules/secure-bucket"

  name               = "iac-course-artifacts-dev-example"
  environment        = "dev"
  kms_key_admin_arns = ["arn:aws:iam::111122223333:role/platform-admin"]
}
