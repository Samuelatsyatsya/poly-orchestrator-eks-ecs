# Terraform settings and required provider versions.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider configuration for this stack.
provider "aws" {
  region = var.region
}
