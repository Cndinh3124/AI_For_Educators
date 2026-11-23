# METADATA
# title: Mandatory tagging
package terraform.tags

import rego.v1

required := {"Environment", "ManagedBy", "Project"}

# Resource types that support tags and must be tagged.
taggable := {"aws_s3_bucket", "aws_kms_key", "aws_iam_role", "aws_instance", "aws_db_instance"}

deny contains msg if {
	some rc in input.resource_changes
	rc.type in taggable
	some action in rc.change.actions
	action in {"create", "update"}
	tags := object.get(rc.change.after, "tags_all", {})
	missing := required - {k | some k, _ in tags}
	count(missing) > 0
	msg := sprintf("%s: missing required tags %v", [rc.address, missing])
}
