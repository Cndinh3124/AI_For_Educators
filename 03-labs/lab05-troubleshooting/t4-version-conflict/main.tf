# Ticket: "After bumping the root to AWS provider 6.x, terraform init fails."
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "legacy" {
  source = "./modules/legacy"
}
