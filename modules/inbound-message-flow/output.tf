output "flow_id" {
  value = genesyscloud_flow.inbound_message_flow.id
}

output "name" {
  value = var.flow_name
}
