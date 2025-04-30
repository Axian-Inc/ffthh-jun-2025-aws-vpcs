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
  description = "Number of Availability Zones to use for the subnets"
  default     = 3
}

variable "public_cidr_block_shift" {
  type        = number
  description = "Number of bits to shift from the VPC CIDR to generate the public CIDR block"
  default     = 1
}

variable "public_subnet_bit_shift" {
  type        = number
  description = "Number of bits to shift from the public CIDR block to generate the public subnet CIDR blocks"
  default     = 2 # Suitable for up to four AZs (subnet_az_count)
}

variable "private_cidr_block_shift" {
  type        = number
  description = "Number of bits to shift from the VPC CIDR block to generate the private CIDR block"
  default     = 1
}

variable "private_subnet_bit_shift" {
  type        = number
  description = "Number of bits to shift from the private CIDR block to generate the private subnet CIDR blocks"
  default     = 2 # Suitable for up to four AZs (subnet_az_count)
}
