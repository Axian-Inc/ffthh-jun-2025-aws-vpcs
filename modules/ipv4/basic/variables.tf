variable "name_prefix" {
  type        = string
  description = "Naming prefix for the resources"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "subnet_az_count" {
  type        = number
  description = "Number of Availability Zones to use for subnets in the VPC"
  default     = 3
}

variable "subnet_cidr_shift" {
  type        = number
  description = "Number of bits to shift from the VPC CIDR block to generate the subnet CIDR blocks"
  default     = 2 # Suitable for up to four AZs (subnet_az_count)
}
