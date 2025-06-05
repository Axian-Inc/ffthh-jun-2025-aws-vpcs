# Create the VPC.
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC CIDR Block
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
# auto-created by AWS for the VPC
resource "aws_route" "public_default" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Create the public IP addresses for the NAT Gateways
resource "aws_eip" "nat" {
  count      = var.subnet_az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags = {
    Name = local.nat_elastic_ip_names[count.index]
  }
}

# Create the NAT Gateways
resource "aws_nat_gateway" "these" {
  count         = var.subnet_az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = {
    Name = local.nat_gateway_names[count.index]
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

# Create a Route Table for each Private Subnet
resource "aws_route_table" "private" {
  count  = var.subnet_az_count
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.private_route_table_names[count.index]
  }
}

# Associate the Route Tables with the Private Subnets
resource "aws_route_table_association" "private" {
  count          = var.subnet_az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create the default routes for NATing
resource "aws_route" "private_default" {
  count                  = var.subnet_az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.these[count.index].id
}
