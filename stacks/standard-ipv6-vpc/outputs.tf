output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "VPC Name"
  value       = module.vpc.vpc_name
}

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "top_level_vpc_ipv6_cidr_blocks" {
  description = "Top-Level IPv6 CIDR blocks in the VPC"
  value       = module.vpc.top_level_vpc_ipv6_cidr_blocks
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "Public Subnet IPv6 CIDR Blocks"
  value       = module.vpc.public_subnet_ipv6_cidr_blocks
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "Private Subnet IPv6 CIDR Blocks"
  value       = module.vpc.private_subnet_ipv6_cidr_blocks
}
