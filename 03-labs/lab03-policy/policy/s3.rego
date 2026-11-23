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
	not attached(bucket, "aws_s3_bucket_public_access_block")
	msg := sprintf("%s: no aws_s3_bucket_public_access_block references this bucket", [bucket.address])
}

# Production buckets must ship server access logs.
deny contains msg if {
	some bucket in changes
	bucket.type == "aws_s3_bucket"
	bucket.change.after.tags_all.Environment == "prod"
	not attached(bucket, "aws_s3_bucket_logging")
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

# A companion resource (PAB, logging...) is "attached" to a bucket when its
# `bucket` argument references that bucket in the configuration. Matching on
# module alone is NOT enough: two buckets + one PAB would pass (see
# fixtures/plan-adversarial.json and 05-ai-review-log, finding F-07).
attached(bucket, type) if {
	some cfg in config_resources
	cfg.resource.type == type
	cfg.module == object.get(bucket, "module_address", "")
	some ref in cfg.resource.expressions.bucket.references
	ref == sprintf("%s.%s", [bucket.type, bucket.name])
}

# Every resource block in the configuration, tagged with its module address
# (e.g. "module.artifacts_bucket"), walking nested module_calls.
config_resources contains {"module": module_address(path), "resource": r} if {
	walk(input.configuration.root_module, [path, r])
	count(path) >= 2
	path[count(path) - 2] == "resources"
}

module_address(path) := concat(".", [sprintf("module.%s", [path[i + 1]]) |
	some i
	path[i] == "module_calls"
])
