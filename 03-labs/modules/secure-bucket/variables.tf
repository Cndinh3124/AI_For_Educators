variable "name" {
  description = "Bucket name (globally unique, lowercase, 3-63 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.name))
    error_message = "Bucket name must be 3-63 chars, lowercase letters, digits, dots or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN for SSE-KMS. Null = create a dedicated key."
  type        = string
  default     = null
}

variable "kms_key_admin_arns" {
  description = "IAM principals allowed to administer the dedicated key (required when kms_key_arn is null)."
  type        = list(string)
  default     = []

  validation {
    condition     = var.kms_key_arn != null || length(var.kms_key_admin_arns) > 0
    error_message = "kms_key_admin_arns must list at least one principal when the module creates its own KMS key."
  }
}

variable "kms_key_user_arns" {
  description = "IAM principals allowed to use the key, only via S3 (kms:ViaService)."
  type        = list(string)
  default     = []
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep noncurrent object versions."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Extra tags merged with mandatory tags."
  type        = map(string)
  default     = {}
}

variable "access_log_bucket" {
  description = "Target bucket for S3 server access logs. Null disables logging (not allowed in prod by policy)."
  type        = string
  default     = null
}
