variable "data_integration_trusted_role_arn" {
  type        = string
  description = "The ARN of the role that the Genesys Cloud Data Integration will use to assume the role to access AWS resources."
}

variable "integration_name" {
  type        = string
  description = "The name of the Genesys Cloud Integration."
  default     = "AWS-Lambda-Integration"
}
