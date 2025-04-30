output "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "subnet_cidr_blocks" {
  description = "Subnet IPv4 CIDR Blocks"
  value       = module.vpc.subnet_cidr_blocks
}
