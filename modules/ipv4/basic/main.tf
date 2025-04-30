# Create the VPC.
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = local.vpc_name
  }
}

# Divvy up the VPC's CIDR block for the Subnets.
module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0"

  base_cidr_block = resource.aws_vpc.this.cidr_block
  networks        = local.subnet_divisions
}

# Create the Subnets.
resource "aws_subnet" "these" {
  count             = var.subnet_az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.these.names[count.index]

  cidr_block              = module.subnet_addrs.network_cidr_blocks[local.subnet_names[count.index]]
  map_public_ip_on_launch = true

  tags = {
    Name = local.subnet_names[count.index]
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
# auto-created by AWS for the VPC.
resource "aws_route" "default" {
  route_table_id         = aws_vpc.this.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
