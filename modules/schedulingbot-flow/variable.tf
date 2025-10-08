variable "bot_name" {
  type        = string
  description = "Name to assign to the Bot Flow."
}

variable "division" {
  type        = string
  description = "Name of the Division to assign to the Bot Flow."
}

variable "lambda_integration_name" {
  type        = string
  description = "The name of the AWS Lambda Integration in Genesys Cloud."
}

variable "get_booking_slots_action_name" {
  type        = string
  description = "The name of the Get Booking Slots Data Action in Genesys Cloud."
}

variable "create_booking_action_name" {
  type        = string
  description = "The name of the Create Booking Data Action in Genesys Cloud."
}

variable "queue_name" {
  type        = string
  description = "The name of the Queue to assign to the Bot Flow."
}
