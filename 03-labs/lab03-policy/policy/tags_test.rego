package terraform.tags_test

import data.terraform.tags

test_missing_tags_reported if {
	some msg in tags.deny with input as {"resource_changes": [{
		"address": "aws_kms_key.k",
		"type": "aws_kms_key",
		"change": {"actions": ["create"], "after": {"tags_all": {"Environment": "dev"}}},
	}]}
	contains(msg, "ManagedBy")
}

test_fully_tagged_passes if {
	count(tags.deny) == 0 with input as {"resource_changes": [{
		"address": "aws_kms_key.k",
		"type": "aws_kms_key",
		"change": {"actions": ["create"], "after": {"tags_all": {"Environment": "dev", "ManagedBy": "terraform", "Project": "x"}}},
	}]}
}

test_delete_not_checked_for_tags if {
	count(tags.deny) == 0 with input as {"resource_changes": [{
		"address": "aws_kms_key.k",
		"type": "aws_kms_key",
		"change": {"actions": ["delete"], "after": null},
	}]}
}
