# Create the VPC
resource "aws_vpc" "this" {
  cidr_block                       = var.ipv4_cidr_block
  assign_generated_ipv6_cidr_block = true # This will be a /56 network.

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC IPv4 CIDR block
module "top_level_vpc_ipv4_cidr_blocks" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.cidr_block
  networks = [
    {
      name     = "public"
      new_bits = var.public_ipv4_cidr_block_shift
    },
    {
      name     = "private"
      new_bits = var.private_ipv4_cidr_block_shift
    }
  ]
}

# Divvy up the Public Subnets for IPv4
module "public_subnet_ipv4_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_ipv4_cidr_blocks.network_cidr_blocks["public"]
  networks        = local.public_subnet_ipv4_divisions
}

# Divvy up the Private Subnets for IPv4
module "private_subnet_ipv4_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_ipv4_cidr_blocks.network_cidr_blocks["private"]
  networks        = local.private_subnet_ipv4_divisions
}

# Divvy up the VPC IPv6 CDR Block
module "top_level_vpc_ipv6_cidr_blocks" {
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

# Divvy up the Public Subnets for IPv6
module "public_subnet_ipv6_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_ipv6_cidr_blocks.network_cidr_blocks["public"]
  networks        = local.public_subnet_ipv6_divisions
}

# Divvy up the Private Subnets for IPv6
module "private_subnet_ipv6_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = module.top_level_vpc_ipv6_cidr_blocks.network_cidr_blocks["private"]
  networks        = local.private_subnet_ipv6_divisions
}

# Create the Public Subnets
resource "aws_subnet" "public" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  # IPv4 Settings
  cidr_block              = module.public_subnet_ipv4_addrs.network_cidr_blocks[local.public_subnet_names[count.index]]
  map_public_ip_on_launch = true

  # IPv6 Settings
  ipv6_cidr_block                 = module.public_subnet_ipv6_addrs.network_cidr_blocks[local.public_subnet_names[count.index]]
  assign_ipv6_address_on_creation = true

  tags = {
    Name = local.public_subnet_names[count.index]
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

# Create the default route and assign it to the route table that was
# auto-created by AWS for the VPC
resource "aws_route" "public_default_ipv4" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_default_ipv6" {
  route_table_id              = aws_vpc.this.default_route_table_id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}

# Create the public IP address for the NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = local.nat_elastic_ip_name
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = local.nat_gateway_name
  }
}

# Create the Private Subnets
resource "aws_subnet" "private" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  # IPv4 Settings
  cidr_block              = module.private_subnet_ipv4_addrs.network_cidr_blocks[local.private_subnet_names[count.index]]
  map_public_ip_on_launch = false

  # IPv6 Settings
  ipv6_cidr_block                 = module.private_subnet_ipv6_addrs.network_cidr_blocks[local.private_subnet_names[count.index]]
  assign_ipv6_address_on_creation = true

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

# Associate the Route Table with each Private Subnet
resource "aws_route_table_association" "private" {
  count          = var.subnet_az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create the default route for IPv4 NATing
resource "aws_route" "private_default_ipv4" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Create the default route for IPv6 Egress-Only
resource "aws_route" "private_default_ipv6" {
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}
