package terraform.blast_radius_test

import data.terraform.blast_radius

test_replace_of_bucket_is_denied if {
	count(blast_radius.deny) == 1 with input as {"resource_changes": [{
		"address": "aws_s3_bucket.data",
		"type": "aws_s3_bucket",
		"change": {"actions": ["delete", "create"]},
	}]}
}

test_delete_of_stateless_resource_is_allowed if {
	count(blast_radius.deny) == 0 with input as {"resource_changes": [{
		"address": "aws_iam_role_policy_attachment.x",
		"type": "aws_iam_role_policy_attachment",
		"change": {"actions": ["delete"]},
	}]}
}

test_update_in_place_is_allowed if {
	count(blast_radius.deny) == 0 with input as {"resource_changes": [{
		"address": "aws_s3_bucket.data",
		"type": "aws_s3_bucket",
		"change": {"actions": ["update"]},
	}]}
}

test_mass_delete_warns if {
	changes := [{"address": sprintf("aws_iam_role.r%d", [i]), "type": "aws_iam_role", "change": {"actions": ["delete"]}} | some i in numbers.range(1, 6)]
	count(blast_radius.warn) == 1 with input as {"resource_changes": changes}
}
