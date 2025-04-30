# Create the VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.ipv4_cidr_block # Used for NAT only.
  assign_generated_ipv6_cidr_block = true                # This will be a /56 network.

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC CIDR block for the Subnets
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.ipv6_cidr_block
  networks        = local.subnet_divisions
}

# Create the Main Subnets
resource "aws_subnet" "public" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  ipv6_cidr_block                 = module.subnet_addrs.network_cidr_blocks[local.subnet_names[count.index]]
  assign_ipv6_address_on_creation = true

  # Because this is IPv6-only
  ipv6_native                                    = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true

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
resource "aws_route" "default_ipv6" {
  route_table_id              = aws_vpc.this.default_route_table_id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

resource "aws_route" "default_ipv4" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Create a public IPv4 subnet to host the NAT gateway
resource "aws_subnet" "nat" {
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[0]

  cidr_block              = aws_vpc.this.cidr_block # Just take the whole thing. We don't need it for anything else.
  map_public_ip_on_launch = true

  tags = {
    Name = local.nat_subnet_name
    Tier = "Public"
  }
}

# Create a public IPv4 address for the NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = local.nat_elastic_ip_name
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.nat.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = local.nat_gateway_name
  }
}

# Intercept the DNS64 network and route it to the NAT gateway.
# (This gets a little weird. After going through the NAT gateway these
# packets will come around again through this same route table, but as
# IPv4 packets instead of IPv6 packets. The 0.0.0.0/0 route will send
# them out through the Internet Gateway.)
resource "aws_route" "nat64" {
  route_table_id              = aws_vpc.this.default_route_table_id
  destination_ipv6_cidr_block = "64:ff9b::/96" # Reserved for NAT64
  nat_gateway_id              = aws_nat_gateway.nat.id
}
