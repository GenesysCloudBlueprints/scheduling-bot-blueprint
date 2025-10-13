# AWS Lambda Function for Scheduling Bot
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/typescript-lambda/dist"
  output_path = "${path.module}/lambda.zip"
  excludes    = [timestamp()]
}

resource "aws_iam_role" "lambda_role" {
  name = "SchedulingBotLambdaRole-${var.environment_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "scheduling_bot" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "scheduling-bot-${var.environment_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      HAPIO_API_ACCESS_TOKEN = var.hapio_api_access_token # this should be stored in a secure way. Can be implemented using AWS Secrets Manager
      HAPIO_LOCATION_ID      = var.hapio_location_id
      HAPIO_SERVICE_ID       = var.hapio_service_id
    }
  }
}

# AWS Lambda Integration Role and Policy for Genesys Cloud
data "genesyscloud_organizations_me" "genesys_cloud_org" {}

resource "aws_iam_role" "genesys_lambda_integration_role" {
  name = "GenesysLambdaIntegrationRole-${var.environment_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          # This is the AWS Account ID for Genesys Cloud.
          # The value inputted is for Core/Satellite regions. 
          # Change to it to 325654371633 for FedRAMP region (US-East-2)
          "AWS" : "arn:aws:iam::765628985471:root"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${data.genesyscloud_organizations_me.genesys_cloud_org.id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "genesys_lambda_invoke_policy" {
  name        = "GenesysLambdaInvokePolicy-${var.environment_name}"
  description = "Policy to allow Genesys Cloud to invoke Lambda functions"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_invoke_policy" {
  role       = aws_iam_role.genesys_lambda_integration_role.name
  policy_arn = aws_iam_policy.genesys_lambda_invoke_policy.arn
}

data "genesyscloud_user" "user" {
  email = var.genesys_user_email
}

# Queue
resource "genesyscloud_routing_queue" "scheduling_queue" {
  name = "Scheduling Queue ${var.environment_name}"
  members {
    user_id = data.genesyscloud_user.user.id
  }
}

# AWS Lambda Integration in Genesys Cloud
module "lambda_integration" {
  source                            = "./modules/aws-integration"
  data_integration_trusted_role_arn = aws_iam_role.genesys_lambda_integration_role.arn
  depends_on                        = [aws_iam_role.genesys_lambda_integration_role, aws_iam_policy.genesys_lambda_invoke_policy, aws_iam_role_policy_attachment.attach_lambda_invoke_policy]
}

# You can also call a data source to get your existing AWS Lambda Integration
# data "genesyscloud_integration" "aws_lambda_integration" {
#   name = "AWS Lambda Integration Name"
# }

# Data Actions
module "get_bookable_slots_action" {
  source              = "./modules/data-actions/get-bookable-slots"
  action_name         = "Get Bookable Slots ${var.environment_name}"
  action_category     = module.lambda_integration.name
  integration_id      = module.lambda_integration.id
  lambda_function_arn = aws_lambda_function.scheduling_bot.arn
  depends_on          = [module.lambda_integration]
}

module "create_booking_action" {
  source              = "./modules/data-actions/create-booking"
  action_name         = "Create Booking ${var.environment_name}"
  action_category     = module.lambda_integration.name
  integration_id      = module.lambda_integration.id
  lambda_function_arn = aws_lambda_function.scheduling_bot.arn
  depends_on          = [module.lambda_integration]
}

# Architect Bot and Inbound Message Flow
module "scheduling_bot" {
  source                        = "./modules/schedulingbot-flow"
  bot_name                      = "Scheduling Bot ${var.environment_name}"
  division                      = var.genesys_division_name
  lambda_integration_name       = module.lambda_integration.name
  get_booking_slots_action_name = module.get_bookable_slots_action.name
  create_booking_action_name    = module.create_booking_action.name
  queue_name                    = genesyscloud_routing_queue.scheduling_queue.name
  depends_on                    = [module.get_bookable_slots_action, module.create_booking_action, genesyscloud_routing_queue.scheduling_queue]
}

module "inbound_message_flow" {
  source        = "./modules/inbound-message-flow"
  flow_name     = "Scheduling Bot Inbound Message Flow ${var.environment_name}"
  division      = var.genesys_division_name
  bot_flow_name = module.scheduling_bot.name
  depends_on    = [module.scheduling_bot]
}

# Messenger Configuration and Deployment
module "messenger_config" {
  source                            = "./modules/webmessenger-configuration"
  web_deployment_configuration_name = "Scheduling Bot Web Messenger Config ${var.environment_name}"
}

module "messenger_deploy" {
  source              = "./modules/webmessenger-deployment"
  web_deployment_name = "Scheduling Bot Web Messenger Deployment ${var.environment_name}"
  flow_id             = module.inbound_message_flow.flow_id
  config_id           = module.messenger_config.config_id
  config_ver          = module.messenger_config.config_ver
  depends_on          = [module.inbound_message_flow]
}
