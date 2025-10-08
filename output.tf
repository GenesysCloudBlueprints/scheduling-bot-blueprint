output "lambda_function_name" {
  value = aws_lambda_function.scheduling_bot.function_name
}

output "genesys_cloud_bot_name" {
  value = module.scheduling_bot.name
}

output "genesys_cloud_inbound_flow_name" {
  value = module.inbound_message_flow.name
}

output "genesys_cloud_messenger_deployment_name" {
  value = module.messenger_deploy.name
}
