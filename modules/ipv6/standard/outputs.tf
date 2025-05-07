output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "VPC Name"
  value       = local.vpc_name
}

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  value       = aws_vpc.this.ipv6_cidr_block
}

output "top_level_vpc_ipv6_cidr_blocks" {
  description = "Top-Level IPv6 CIDR blocks in the VPC"
  value       = module.top_level_vpc_cidr_blocks.network_cidr_blocks
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "Public Subnet IPv6 CIDR Blocks"
  value       = module.public_subnet_addrs.network_cidr_blocks
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "Private Subnet IPv6 CIDR Blocks"
  value       = module.private_subnet_addrs.network_cidr_blocks
}
