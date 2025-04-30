locals {
  all_az_names      = data.aws_availability_zones.these.names
  all_az_letters    = [for az_name in local.all_az_names : substr(az_name, -1, 1)]
  subnet_az_letters = slice(local.all_az_letters, 0, var.subnet_az_count)

  vpc_name              = "${var.name_prefix}-vpc"
  internet_gateway_name = "${var.name_prefix}-igw"

  route_table_name_prefix = "${var.name_prefix}-rtb"
  route_table_names       = [for az_letter in local.subnet_az_letters : "${local.route_table_name_prefix}-${az_letter}"]

  subnet_name_prefix = "${var.name_prefix}-subnet"
  subnet_names       = [for az_letter in local.subnet_az_letters : "${local.subnet_name_prefix}-${az_letter}"]
  subnet_divisions   = [for subnet_name in local.subnet_names : { name = subnet_name, new_bits = 8 }]

  nat_subnet_name_prefix = "${var.name_prefix}-nat-subnet"
  nat_subnet_names       = [for az_letter in local.subnet_az_letters : "${local.nat_subnet_name_prefix}-${az_letter}"]
  nat_subnet_divisions   = [for subnet_name in local.nat_subnet_names : { name = subnet_name, new_bits = var.subnet_ipv4_cidr_shift }]

  nat_elastic_ip_name_prefix = "${var.name_prefix}-nat-eip"
  nat_elastic_ip_names       = [for az_letter in local.subnet_az_letters : "${local.nat_elastic_ip_name_prefix}-${az_letter}"]

  nat_gateway_name_prefix = "${var.name_prefix}-nat"
  nat_gateway_names       = [for az_letter in local.subnet_az_letters : "${local.nat_gateway_name_prefix}-${az_letter}"]
}
