terraform {
  required_version = ">= 0.12"
  backend "s3" {
    encrypt                 = true
    bucket                  = "plana-ch2-terraform-state"
    dynamodb_table          = "plana-ch2-state-lock-dynamo"
    region                  = "us-east-1"
    workspace_key_prefix    = "homolog"
    key                     = "terraform.tfstate"
    profile                 = "default"
    shared_credentials_file = "~/.aws/credentials"
  }
}



provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjunction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}
