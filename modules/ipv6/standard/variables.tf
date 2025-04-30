variable "name_prefix" {
  type        = string
  description = "Naming prefix for the resources"
}

variable "subnet_az_count" {
  type        = number
  description = "Number of Availability Zones to use for subnets in the VPC"
  default     = 3
}
