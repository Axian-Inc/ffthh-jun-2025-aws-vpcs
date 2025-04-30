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

variable "subnet_ipv4_cidr_shift" {
  type        = number
  description = "Number of bits to shift from the VPC IPv4 CIDR block to generate the subnet IPv4 CIDR blocks"
  default     = 2 # Suitable for up to four AZs (subnet_az_count)
}
