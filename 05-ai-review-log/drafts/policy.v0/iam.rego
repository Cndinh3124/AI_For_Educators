# METADATA
# title: IAM least privilege
package terraform.iam

import rego.v1

policy_types := {"aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy", "aws_iam_group_policy"}

deny contains msg if {
	some rc in input.resource_changes
	rc.type in policy_types
	doc := json.unmarshal(rc.change.after.policy)
	some stmt in as_array(doc.Statement)
	stmt.Effect == "Allow"
	"*" in as_array(stmt.Action)
	msg := sprintf("%s: Allow with Action \"*\" is forbidden", [rc.address])
}

deny contains msg if {
	some rc in input.resource_changes
	rc.type in policy_types
	doc := json.unmarshal(rc.change.after.policy)
	some stmt in as_array(doc.Statement)
	stmt.Effect == "Allow"
	"*" in as_array(stmt.Resource)
	some action in as_array(stmt.Action)
	endswith(action, ":*")
	msg := sprintf("%s: service-wide action %s on Resource \"*\"", [rc.address, action])
}

as_array(x) := x if is_array(x)

as_array(x) := [x] if not is_array(x)
