# Create the VPC
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC CIDR block
module "top_level_vpc_cidr_blocks" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.cidr_block
  networks = [
    {
      name     = "public"
      new_bits = var.public_cidr_block_shift
    },
    {
      name     = "private"
      new_bits = var.private_cidr_block_shift
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

# Create the Public Subnets
resource "aws_subnet" "public" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  cidr_block              = module.public_subnet_addrs.network_cidr_blocks[local.public_subnet_names[count.index]]
  map_public_ip_on_launch = true

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
# auto-created by AWS for the VPC.
resource "aws_route" "public_default" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Create the public IP address for the NAT Gateway.
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

  cidr_block              = module.private_subnet_addrs.network_cidr_blocks[local.private_subnet_names[count.index]]
  map_public_ip_on_launch = false

  tags = {
    Name = local.private_subnet_names[count.index]
    Tier = "Private"
  }
}

# Create a Route Table for the Private Subnets.
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

# Create the default route for NATing
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
