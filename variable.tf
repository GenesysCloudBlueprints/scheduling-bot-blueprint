variable "aws_region" {
  type        = string
  description = "AWS Region where you want to deploy the AWS resources."
}

variable "environment_name" {
  type        = string
  description = "The affix that will be added to resources to determine its environment."
  default     = "dev"
}

variable "hapio_api_access_token" {
  description = "Hapio API access token"
  type        = string
  sensitive   = true
}

variable "hapio_location_id" {
  description = "Hapio location ID"
  type        = string
}

variable "hapio_service_id" {
  description = "Hapio service ID"
  type        = string
}

variable "genesys_division_name" {
  description = "The name of the Genesys Cloud division where you want to deploy the bot and flow."
  type        = string
  default     = "Default"
}

variable "genesys_user_email" {
  description = "Email of the Genesys Cloud user who will be added to the generated queue"
  type        = string
}
