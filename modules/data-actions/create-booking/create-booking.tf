resource "genesyscloud_integration_action" "create_booking" {
  name           = var.action_name
  category       = var.action_category
  integration_id = var.integration_id
  contract_input = jsonencode({
    "type" : "object",
    "required" : [
      "start_time",
      "end_time"
    ],
    "properties" : {
      "start_time" : {
        "type" : "string",
        "description" : "Start time given from Hapio. In ISO format."
      },
      "end_time" : {
        "type" : "string",
        "description" : "End time given from Hapio. In ISO format."
      }
    }
  })
  contract_output = jsonencode({
    "type" : "object",
    "required" : [
      "id"
    ],
    "properties" : {
      "id" : {
        "type" : "string"
      }
    }
  })
  config_request {
    # Use '$${' to indicate a literal '${' in template strings. Otherwise Terraform will attempt to interpolate the string
    # See https://www.terraform.io/docs/language/expressions/strings.html#escape-sequences
    request_url_template = var.lambda_function_arn
    request_type         = "POST"
    headers              = {}
    request_template     = "{\n  \"type\": \"createBooking\",\n  \"body\": {\n    \"start_time\": \"$${input.start_time}\",\n    \"end_time\": \"$${input.end_time}\"\n  }\n}"
  }
  config_response {
    translation_map          = {}
    translation_map_defaults = {}
    success_template         = "$${rawResult}"
  }
}
