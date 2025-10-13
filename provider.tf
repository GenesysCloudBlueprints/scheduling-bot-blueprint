terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
