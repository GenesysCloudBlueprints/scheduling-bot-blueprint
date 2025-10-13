resource "genesyscloud_integration_credential" "LambdaIntegrationCredentials" {
  name                 = "AWSLambdaIntegrationCredentials"
  credential_type_name = "amazonWebServicesARN"
  fields = {
    ARN = var.data_integration_trusted_role_arn
  }
}

resource "genesyscloud_integration" "LambdaDataIntegration" {
  intended_state   = "ENABLED"
  integration_type = "aws-lambda-data-actions"
  config {
    name        = var.integration_name
    properties  = jsonencode({})
    advanced    = jsonencode({})
    credentials = { "AmazonWebServicesARN" : "${genesyscloud_integration_credential.LambdaIntegrationCredentials.id}" }
    notes       = "Integration created to invoke an AWS Lambda"
  }
}
