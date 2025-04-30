variable "name_prefix" {
  type        = string
  description = "Naming prefix for the resources"
}

variable "ipv4_cidr_block" {
  type        = string
  description = "Minimal IPv4 CIDR block used for NAT"
  default     = "192.168.100.0/24"
}

variable "subnet_az_count" {
  type        = number
  description = "Number of Availability Zones to use for subnets in the VPC"
  default     = 3
}
