# Create the VPC
resource "aws_vpc" "this" {
  cidr_block                       = "192.168.100.0/24" # Not used at all but AWS requires a value.
  assign_generated_ipv6_cidr_block = true               # This will be a /56 network.

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC IPv6 CIDR Block
module "top_level_vpc_cidr_blocks" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.ipv6_cidr_block
  networks = [
    {
      name     = "public"
      new_bits = 4
    },
    {
      name     = "private"
      new_bits = 4
    }
  ]
}

# Divvy up the Public Subnets
module "public_subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_cidr_blocks.network_cidr_blocks["public"]
  networks        = local.public_subnet_divisions
}

# Divvy up the Private Subnets
module "private_subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_cidr_blocks.network_cidr_blocks["private"]
  networks        = local.private_subnet_divisions
}

# Create the Public Subnets.
resource "aws_subnet" "public" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = module.public_subnet_addrs.network_cidr_blocks[local.public_subnet_names[count.index]]

  # Because this is IPv6-only
  ipv6_native                                    = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true

  tags = {
    Name = local.public_subnet_names[count.index]
    Tier = "Public"
  }
}

# Create the Internet Gateway.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.internet_gateway_name
  }
}

# Create the default route and assign it to the route table that was
# auto-created by AWS for the VPC
resource "aws_route" "public_default_ipv6" {
  route_table_id              = aws_vpc.this.default_route_table_id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

# Create the Private Subnets.
resource "aws_subnet" "private" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  ipv6_cidr_block                 = module.private_subnet_addrs.network_cidr_blocks[local.private_subnet_names[count.index]]
  assign_ipv6_address_on_creation = true

  # Because this is IPv6-only
  ipv6_native                                    = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true

  tags = {
    Name = local.private_subnet_names[count.index]
    Tier = "Private"
  }
}

# Create the Egress-Only Internet Gateway
resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.egress_only_internet_gateway_name
  }
}

# Create a Route Table for the Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.private_route_table_name
  }
}

# Associate the Route Table with the Private Subnets.
resource "aws_route_table_association" "private" {
  count          = var.subnet_az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create the default routes and assign them to the route table for
# the Private Subnets.
resource "aws_route" "private_default_ipv6" {
  count                       = var.subnet_az_count
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}
