output "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "top_level_vpc_cidr_blocks" {
  description = "Top-Level IPv4 CIDR blocks in the VPC"
  value       = module.vpc.top_level_vpc_cidr_blocks
}

output "public_subnet_cidr_blocks" {
  description = "Public Subnet IPv4 CIDR Blocks"
  value       = module.vpc.public_subnet_cidr_blocks
}

output "private_subnet_cidr_blocks" {
  description = "Private Subnet IPv4 CIDR Blocks"
  value       = module.vpc.private_subnet_cidr_blocks
}