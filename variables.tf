variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "app_private_subnet_cidrs" {
  type = list(string)
}

variable "db_private_subnet_cidrs" {
  type = list(string)
}

variable "project" {
  type = string
}