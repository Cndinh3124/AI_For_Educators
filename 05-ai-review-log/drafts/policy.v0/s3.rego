# METADATA
# title: S3 baseline guardrails
# description: Evaluated against `terraform show -json` plan output.
package terraform.s3

import rego.v1

changes contains rc if {
	some rc in input.resource_changes
	not "delete" in rc.change.actions
	rc.change.actions != ["no-op"]
}

# Each planned bucket must have a public access block with all 4 flags = true.
deny contains msg if {
	some pab in changes
	pab.type == "aws_s3_bucket_public_access_block"
	some flag in ["block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"]
	pab.change.after[flag] != true
	msg := sprintf("%s: %s must be true", [pab.address, flag])
}

deny contains msg if {
	some bucket in changes
	bucket.type == "aws_s3_bucket"
	not has_sibling(bucket, "aws_s3_bucket_public_access_block")
	msg := sprintf("%s: no aws_s3_bucket_public_access_block in the same module", [bucket.address])
}

# Production buckets must ship server access logs.
deny contains msg if {
	some bucket in changes
	bucket.type == "aws_s3_bucket"
	bucket.change.after.tags_all.Environment == "prod"
	not has_sibling(bucket, "aws_s3_bucket_logging")
	msg := sprintf("%s: prod buckets require aws_s3_bucket_logging", [bucket.address])
}

# SSE must use KMS, not SSE-S3 (AES256).
deny contains msg if {
	some sse in changes
	sse.type == "aws_s3_bucket_server_side_encryption_configuration"
	some rule in sse.change.after.rule
	some d in rule.apply_server_side_encryption_by_default
	d.sse_algorithm != "aws:kms"
	msg := sprintf("%s: sse_algorithm must be aws:kms (got %s)", [sse.address, d.sse_algorithm])
}

has_sibling(res, type) if {
	some other in changes
	other.type == type
	object.get(other, "module_address", "") == object.get(res, "module_address", "")
}
