# IPv4

output "vpc_ipv4_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  value       = module.vpc.vpc_ipv4_cidr_block
}

output "subnet_ipv4_cidr_blocks" {
  description = "Subnet IPv4 CIDR Blocks"
  value       = module.vpc.subnet_ipv4_cidr_blocks
}

# IPv6

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "subnet_ipv6_cidr_blocks" {
  description = "Subnet IPv6 CIDR Blocks"
  value       = module.vpc.subnet_ipv6_cidr_blocks
}
