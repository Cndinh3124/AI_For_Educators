mock_provider "aws" {
  # Mocked `json` is a random string; give the policy document valid JSON.
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

  # TODO: assert that key rotation is enabled
}

run "public_access_fully_blocked" {
  command = plan

  # TODO: assert all four aws_s3_bucket_public_access_block flags are true (hint: alltrue([...]))
}

run "rejects_uppercase_bucket_name" {
  command = plan

  variables {
    name = "Invalid_Bucket"
  }

  # TODO: this run must succeed only if validation on var.name rejects the input
}
