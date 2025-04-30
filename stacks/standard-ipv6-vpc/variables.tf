variable "account_id" {
  type        = string
  description = "AWS account in which to provision the resources"
}

variable "region" {
  type        = string
  description = "AWS region in which to provision the resources"
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "Naming prefix for the resources"
}

variable "subnet_az_count" {
  type        = number
  description = "Number of Availability Zones to use for subnets in the VPC"
  default     = 3
}