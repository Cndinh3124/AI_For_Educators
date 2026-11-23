# Ticket: "CI fails right after someone turned the single bucket into a list of buckets."
variable "bucket_names" {
  type    = list(string)
  default = ["iac-course-logs-example", "iac-course-assets-example"]
}

resource "aws_s3_bucket" "this" {
  for_each = var.bucket_names
  bucket   = each.value
}
