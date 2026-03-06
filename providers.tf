# Providers Configuration
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  # Remote Backend
  backend "s3" {
    bucket       = "demo-pdpredi"
    key          = "vpc/terraform.tfstate"
    region       = "ap-south-2"
    encrypt      = true
    use_lockfile = true
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = "staging"
    }
  }
}