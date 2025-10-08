output "config_id" {
  value = genesyscloud_webdeployments_configuration.web_message_configuration.id
}

output "config_ver" {
  value = genesyscloud_webdeployments_configuration.web_message_configuration.version
}

output "config_name" {
  value = var.web_deployment_configuration_name
}
