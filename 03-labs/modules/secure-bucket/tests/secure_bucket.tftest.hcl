# Mock providers return random strings for computed attributes, so a policy
# document's `json` would be invalid JSON. Override it with a valid document and
# assert on the *inputs* of the policy instead (review finding H-01b).
mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.kms
    values = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  name               = "iac-course-test-bucket"
  environment        = "dev"
  kms_key_admin_arns = ["arn:aws:iam::111122223333:role/platform-admin"]
}

run "creates_dedicated_kms_key_when_none_given" {
  command = plan

  assert {
    condition     = length(aws_kms_key.this) == 1
    error_message = "A dedicated KMS key must be created when kms_key_arn is null."
  }

  assert {
    condition     = aws_kms_key.this[0].enable_key_rotation == true
    error_message = "KMS key rotation must be enabled."
  }
}

run "public_access_fully_blocked" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets,
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
    condition     = length(aws_kms_key.this) == 0
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

run "logging_enabled_when_target_given" {
  command = plan

  variables {
    access_log_bucket = "central-access-logs-example"
  }

  assert {
    condition     = aws_s3_bucket_logging.this[0].target_prefix == "s3/iac-course-test-bucket/"
    error_message = "Access logs must be written under s3/<bucket-name>/."
  }
}

run "abort_incomplete_multipart_uploads" {
  command = plan

  assert {
    condition     = one(one(aws_s3_bucket_lifecycle_configuration.this.rule).abort_incomplete_multipart_upload).days_after_initiation == 7
    error_message = "Incomplete multipart uploads must be aborted after 7 days."
  }
}

run "key_policy_is_explicit" {
  command = plan

  assert {
    condition     = data.aws_iam_policy_document.kms[0].statement[0].sid == "KeyAdministration"
    error_message = "The dedicated key must carry an explicit key administration statement."
  }

  assert {
    condition     = one(data.aws_iam_policy_document.kms[0].statement[0].principals).identifiers == toset(["arn:aws:iam::111122223333:role/platform-admin"])
    error_message = "Only the declared admin principals may administer the key."
  }
}

run "rejects_own_key_without_admins" {
  command = plan

  variables {
    kms_key_admin_arns = []
  }

  expect_failures = [var.kms_key_admin_arns]
}

run "key_usage_restricted_to_s3" {
  command = plan

  variables {
    kms_key_user_arns = ["arn:aws:iam::111122223333:role/doc-intake-app"]
  }

  assert {
    condition     = one(data.aws_iam_policy_document.kms[0].statement[1].condition).values == tolist(["s3.*.amazonaws.com"])
    error_message = "Key usage must be restricted to calls made via S3."
  }
}
