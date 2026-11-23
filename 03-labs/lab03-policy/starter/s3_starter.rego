package terraform.s3

# Hint: input.resource_changes[_] has .type, .address, .module_address, .change.actions, .change.after
# Hint: input.configuration.root_module.resources[_].expressions.bucket.references lists what a resource points at

deny contains msg if {
	some rc in input.resource_changes
	rc.type == "aws_s3_bucket_public_access_block"

	# TODO: check the four flags
	msg := sprintf("%s: TODO", [rc.address])
}

# TODO (main path): prod buckets (tags_all.Environment == "prod") must have
# aws_s3_bucket_logging attached — use the helper below.

# ---- Provided helper (main path). Extension task: rewrite it yourself. ----
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
