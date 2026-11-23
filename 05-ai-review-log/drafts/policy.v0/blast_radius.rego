# METADATA
# title: Blast-radius guard for stateful resources
package terraform.blast_radius

import rego.v1

protected := {"aws_s3_bucket", "aws_kms_key", "aws_db_instance", "aws_dynamodb_table", "aws_rds_cluster"}

# Delete (including replace = delete+create) of stateful resources needs a human.
deny contains msg if {
	some rc in input.resource_changes
	rc.type in protected
	"delete" in rc.change.actions
	msg := sprintf("%s: planned %v on a stateful resource — requires manual approval", [rc.address, rc.change.actions])
}

warn contains msg if {
	n := count([rc | some rc in input.resource_changes; "delete" in rc.change.actions])
	n > 5
	msg := sprintf("plan deletes %d resources — review blast radius", [n])
}
