# This file defines local variables for the VPC module, including availability zones and subnet configurations.
locals {

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = {
    for i, cidr in var.public_subnet_cidrs :
    "public-${i}" => {
      cidr = cidr
      az   = local.azs[i]
    }
  }

  private_app_subnets = {
    for i, cidr in var.app_private_subnet_cidrs :
    "app-${i}" => {
      cidr = cidr
      az   = local.azs[i]
    }
  }

  private_db_subnets = {
    for i, cidr in var.db_private_subnet_cidrs :
    "db-${i}" => {
      cidr = cidr
      az   = local.azs[i]
    }
  }
}