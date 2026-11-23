# Ticket: "Fresh environment: plan fails, but it works in the existing dev workspace."
resource "aws_kms_key" "logs" {
  description         = "logs key"
  enable_key_rotation = true
}

resource "aws_cloudwatch_log_group" "app" {
  # Intent: only create when encryption is configured.
  count      = aws_kms_key.logs.arn != "" ? 1 : 0
  name       = "/iac-course/app"
  kms_key_id = aws_kms_key.logs.arn
}
