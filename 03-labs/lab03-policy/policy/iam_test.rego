package terraform.iam_test

import data.terraform.iam

policy_input(doc) := {"resource_changes": [{
	"address": "aws_iam_policy.p",
	"type": "aws_iam_policy",
	"change": {"actions": ["create"], "after": {"policy": json.marshal(doc)}},
}]}

test_scoped_policy_passes if {
	count(iam.deny) == 0 with input as policy_input({"Statement": [{
		"Effect": "Allow",
		"Action": ["s3:GetObject"],
		"Resource": "arn:aws:s3:::bucket/*",
	}]})
}

test_single_statement_object_is_handled if {
	count(iam.deny) == 1 with input as policy_input({"Statement": {"Effect": "Allow", "Action": "*", "Resource": "*"}})
}

test_deny_wildcard_is_not_flagged if {
	count(iam.deny) == 0 with input as policy_input({"Statement": [{"Effect": "Deny", "Action": "*", "Resource": "*"}]})
}
