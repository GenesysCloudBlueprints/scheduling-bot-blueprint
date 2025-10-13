resource "genesyscloud_flow" "inbound_message_flow" {
  filepath = "${path.module}/SchedulerBotInboundMessageFlow.yaml"
  substitutions = {
    flow_name        = var.flow_name
    division         = var.division
    default_language = "en-us"
    bot_flow_name    = var.bot_flow_name
  }
}
