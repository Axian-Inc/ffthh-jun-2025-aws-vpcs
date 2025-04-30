output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "subnet_ipv6_cidr_blocks" {
  description = "Subnet IPv6 CIDR Blocks"
  value       = module.vpc.subnet_ipv6_cidr_blocks
}
