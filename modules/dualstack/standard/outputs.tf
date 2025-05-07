# VPC

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "VPC Name"
  value       = local.vpc_name
}

# IPv4

output "vpc_ipv4_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  value       = aws_vpc.this.cidr_block
}

output "top_level_vpc_ipv4_cidr_blocks" {
  description = "Top-Level IPv4 CIDR blocks in the VPC"
  value       = module.top_level_vpc_ipv4_cidr_blocks.network_cidr_blocks
}

output "public_subnet_ipv4_cidr_blocks" {
  description = "Public Subnet IPv4 CIDR Blocks"
  value       = module.public_subnet_ipv4_addrs.network_cidr_blocks
}

output "private_subnet_ipv4_cidr_blocks" {
  description = "Private Subnet IPv4 CIDR Blocks"
  value       = module.private_subnet_ipv4_addrs.network_cidr_blocks
}

# IPv6

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  value       = aws_vpc.this.ipv6_cidr_block
}

output "top_level_vpc_ipv6_cidr_blocks" {
  description = "Top-Level IPv6 CIDR blocks in the VPC"
  value       = module.top_level_vpc_ipv6_cidr_blocks.network_cidr_blocks
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "Public Subnet IPv6 CIDR Blocks"
  value       = module.public_subnet_ipv6_addrs.network_cidr_blocks
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "Private Subnet CIDR IPv6 Blocks"
  value       = module.private_subnet_ipv6_addrs.network_cidr_blocks
}
