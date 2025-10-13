resource "genesyscloud_flow" "bot_flow" {
  filepath          = "${path.module}/SchedulingBot.yaml"
  substitutions = {
    bot_name                      = var.bot_name
    division                      = var.division
    default_language              = "en-us"
    lambda_integration_name       = var.lambda_integration_name
    get_booking_slots_action_name = var.get_booking_slots_action_name
    create_booking_action_name    = var.create_booking_action_name
    queue_name                    = var.queue_name
  }
}
