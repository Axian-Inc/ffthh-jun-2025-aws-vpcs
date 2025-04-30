locals {
  all_az_names      = data.aws_availability_zones.these.names
  all_az_letters    = [for az_name in local.all_az_names : substr(az_name, -1, 1)]
  subnet_az_letters = slice(local.all_az_letters, 0, var.subnet_az_count)

  vpc_name              = "${var.name_prefix}-vpc"
  internet_gateway_name = "${var.name_prefix}-igw"

  nat_elastic_ip_name = "${var.name_prefix}-nat-eip"
  nat_gateway_name    = "${var.name_prefix}-nat"
  nat_subnet_name     = "${var.name_prefix}-nat-subnet"

  subnet_name_prefix = "${var.name_prefix}-subnet"
  subnet_names       = [for az_letter in local.subnet_az_letters : "${local.subnet_name_prefix}-${az_letter}"]
  subnet_divisions   = [for subnet_name in local.subnet_names : { name = subnet_name, new_bits = 8 }]
}
