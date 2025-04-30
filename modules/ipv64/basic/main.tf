# Create the VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.ipv4_cidr_block # Used for NAT only.
  assign_generated_ipv6_cidr_block = true                # This will be a /56 network.

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC IPv6 CIDR block for the Subnets
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.ipv6_cidr_block
  networks        = local.subnet_divisions
}

# Divvy up the VPC IPv4 CIDR block for the NAT Subnets
module "nat_subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.cidr_block
  networks        = local.nat_subnet_divisions
}

# Create the Main Subnets.
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

# Create a Route Table for each subnet. Note that we're not leveraging the
# AWS-provided route table for these subnets.
resource "aws_route_table" "public" {
  count  = var.subnet_az_count
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.route_table_names[count.index]
  }
}

# Associate the Route Tables with the subnets
resource "aws_route_table_association" "public" {
  count          = var.subnet_az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# Create the default routes and assign them to the route tables
# for each subnet. Note that *so far* the routes for each subnet
# are identical. That will change when the NAT route is added.
resource "aws_route" "default_ipv6" {
  count                       = var.subnet_az_count
  route_table_id              = aws_route_table.public[count.index].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

resource "aws_route" "default_ipv4" {
  count                  = var.subnet_az_count
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Create public IPv4 subnets to host the NAT gateways
resource "aws_subnet" "nat" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  cidr_block              = module.nat_subnet_addrs.network_cidr_blocks[local.nat_subnet_names[count.index]]
  map_public_ip_on_launch = true

  tags = {
    Name = local.nat_subnet_names[count.index]
    Tier = "Public"
  }
}

# Since we're using the AWS-provided route table for these subnets, we
# need make sure there is a default route for that, but just for IPv4.
resource "aws_route" "nat_default_ipv4" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Create a public IPv4 addresses for each NAT gateway
resource "aws_eip" "nat" {
  count  = var.subnet_az_count
  domain = "vpc"

  tags = {
    Name = local.nat_elastic_ip_names[count.index]
  }
}

# Create the NAT Gateways
resource "aws_nat_gateway" "nat" {
  count         = var.subnet_az_count
  subnet_id     = aws_subnet.nat[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = {
    Name = local.nat_gateway_names[count.index]
  }
}

# Intercept the DNS64 network and route it to the NAT gateways.
# (This is where the route tables for each of the subnets diverge.)
resource "aws_route" "nat64" {
  count                       = var.subnet_az_count
  route_table_id              = aws_route_table.public[count.index].id
  destination_ipv6_cidr_block = "64:ff9b::/96" # Reserved for NAT64
  nat_gateway_id              = aws_nat_gateway.nat[count.index].id
}
