locals {
  all_az_names      = data.aws_availability_zones.these.names
  all_az_letters    = [for az_name in local.all_az_names : substr(az_name, -1, 1)]
  subnet_az_letters = slice(local.all_az_letters, 0, var.subnet_az_count)

  vpc_name              = "${var.name_prefix}-vpc"
  internet_gateway_name = "${var.name_prefix}-igw"

  egress_only_internet_gateway_name = "${var.name_prefix}-eigw"

  public_route_table_name_prefix = "${var.name_prefix}-public-rtb"
  public_route_table_names       = [for az_letter in local.subnet_az_letters : "${local.public_route_table_name_prefix}-${az_letter}"]

  public_subnet_name_prefix = "${var.name_prefix}-public-subnet"
  public_subnet_names       = [for az_letter in local.subnet_az_letters : "${local.public_subnet_name_prefix}-${az_letter}"]
  public_subnet_divisions   = [for subnet_name in local.public_subnet_names : { name = subnet_name, new_bits = 4 }]

  private_route_table_name_prefix = "${var.name_prefix}-private-rtb"
  private_route_table_names       = [for az_letter in local.subnet_az_letters : "${local.private_route_table_name_prefix}-${az_letter}"]

  private_subnet_name_prefix = "${var.name_prefix}-private-subnet"
  private_subnet_names       = [for az_letter in local.subnet_az_letters : "${local.private_subnet_name_prefix}-${az_letter}"]
  private_subnet_divisions   = [for subnet_name in local.private_subnet_names : { name = subnet_name, new_bits = 4 }]

  nat_subnet_name_prefix = "${var.name_prefix}-nat-subnet"
  nat_subnet_names       = [for az_letter in local.subnet_az_letters : "${local.nat_subnet_name_prefix}-${az_letter}"]
  nat_subnet_divisions   = [for subnet_name in local.nat_subnet_names : { name = subnet_name, new_bits = var.subnet_ipv4_cidr_shift }]

  nat_elastic_ip_name_prefix = "${var.name_prefix}-nat-eip"
  nat_elastic_ip_names       = [for az_letter in local.subnet_az_letters : "${local.nat_elastic_ip_name_prefix}-${az_letter}"]

  nat_gateway_name_prefix = "${var.name_prefix}-nat"
  nat_gateway_names       = [for az_letter in local.subnet_az_letters : "${local.nat_gateway_name_prefix}-${az_letter}"]
}
