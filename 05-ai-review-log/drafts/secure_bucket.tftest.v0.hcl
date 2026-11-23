mock_provider "aws" {}

variables {
  name        = "iac-course-test-bucket"
  environment = "dev"
}

run "creates_dedicated_kms_key_when_none_given" {
  command = plan

  assert {
    condition     = length(module.bucket.aws_kms_key.this) == 1
    error_message = "A dedicated KMS key must be created when kms_key_arn is null."
  }

  assert {
    condition     = module.bucket.aws_kms_key.this[0].enable_key_rotation == true
    error_message = "KMS key rotation must be enabled."
  }
}

run "public_access_fully_blocked" {
  command = plan

  assert {
    condition = alltrue([
      module.bucket.aws_s3_bucket_public_access_block.this.block_public_acls,
      module.bucket.aws_s3_bucket_public_access_block.this.block_public_policy,
      module.bucket.aws_s3_bucket_public_access_block.this.ignore_public_acls,
      module.bucket.aws_s3_bucket_public_access_block.this.restrict_public_buckets,
    ])
    error_message = "All four public access block flags must be true."
  }
}

run "reuses_external_kms_key" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:ap-southeast-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = length(module.bucket.aws_kms_key.this) == 0
    error_message = "No key should be created when kms_key_arn is supplied."
  }
}

run "rejects_invalid_environment" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "rejects_uppercase_bucket_name" {
  command = plan

  variables {
    name = "Invalid_Bucket"
  }

  expect_failures = [var.name]
}
