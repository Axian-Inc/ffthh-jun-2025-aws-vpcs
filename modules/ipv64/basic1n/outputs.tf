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

output "subnet_ipv6_cidr_blocks" {
  description = "Subnet IPv6 CIDR Blocks"
  value       = module.subnet_addrs.network_cidr_blocks
}
