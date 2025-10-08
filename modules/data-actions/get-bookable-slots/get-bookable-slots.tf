resource "genesyscloud_integration_action" "get_bookable_slots" {
  name           = var.action_name
  category       = var.action_category
  integration_id = var.integration_id
  contract_input = jsonencode({
    "type" : "object",
    "required" : [
      "date"
    ],
    "properties" : {
      "date" : {
        "type" : "string",
        "description" : "Date of the slots that you want to check. Format should be YYYY-MM-DD"
      }
    }
  })
  contract_output = jsonencode({
    "type" : "object",
    "required" : [
      "start_time",
      "end_time",
      "time_complete"
    ],
    "properties" : {
      "time" : {
        "type" : "array",
        "items" : {
          "type" : "string"
        }
      },
      "start_time" : {
        "type" : "array",
        "items" : {
          "type" : "string"
        }
      },
      "end_time" : {
        "type" : "array",
        "items" : {
          "type" : "string"
        }
      },
      "time_complete" : {
        "type" : "array",
        "items" : {
          "type" : "string"
        }
      }
    }
  })
  config_request {
    # Use '$${' to indicate a literal '${' in template strings. Otherwise Terraform will attempt to interpolate the string
    # See https://www.terraform.io/docs/language/expressions/strings.html#escape-sequences
    request_url_template = var.lambda_function_arn
    request_type         = "POST"
    headers              = {}
    request_template     = "{\n  \"type\": \"getBookableSlots\",\n  \"body\": {\n    \"date\": \"$${input.date}\"\n  }\n}"
  }
  config_response {
    translation_map          = {}
    translation_map_defaults = {}
    success_template         = "$${rawResult}"
  }
}
