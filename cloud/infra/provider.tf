provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket                  = "zdrovi-infra"
    key                     = "terraform_state/infra"
    region                  = "eu-central-1"
  }
}