output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "VPC Name"
  value       = local.vpc_name
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  value       = aws_vpc.this.cidr_block
}

output "top_level_vpc_cidr_blocks" {
  description = "Top-Level IPv4 CIDR blocks in the VPC"
  value       = module.top_level_vpc_cidr_blocks.network_cidr_blocks
}

output "public_subnet_cidr_blocks" {
  description = "Public Subnet IPv4 CIDR Blocks"
  value       = module.public_subnet_addrs.network_cidr_blocks
}

output "private_subnet_cidr_blocks" {
  description = "Private Subnet IPv4 CIDR Blocks"
  value       = module.private_subnet_addrs.network_cidr_blocks
}
