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

output "subnet_cidr_blocks" {
  description = "Subnet IPv4 CIDR Blocks"
  value       = module.subnet_addrs.network_cidr_blocks
}
