# Create the VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.ipv4_cidr_block
  assign_generated_ipv6_cidr_block = true # This will be a /56 network.

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC IPv4 CIDR block for the Subnets.
module "subnet_ipv4_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.cidr_block
  networks        = local.subnet_ipv4_divisions
}

# Divvy up the VPC IPv6 CIDR block for the Subnets.
module "subnet_ipv6_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.ipv6_cidr_block
  networks        = local.subnet_ipv6_divisions
}

# Create the Subnets
resource "aws_subnet" "public" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  # IPv4 Settings
  cidr_block              = module.subnet_ipv4_addrs.network_cidr_blocks[local.subnet_names[count.index]]
  map_public_ip_on_launch = true

  # IPv6 Settings
  ipv6_cidr_block                 = module.subnet_ipv6_addrs.network_cidr_blocks[local.subnet_names[count.index]]
  assign_ipv6_address_on_creation = true

  tags = {
    Name = local.subnet_names[count.index]
    Tier = "Public"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.internet_gateway_name
  }
}

# Create the default routes and assign them to the route table that was
# auto-created by AWS for the VPC.
resource "aws_route" "default_ipv4" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "default_ipv6" {
  route_table_id              = aws_vpc.this.default_route_table_id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}
