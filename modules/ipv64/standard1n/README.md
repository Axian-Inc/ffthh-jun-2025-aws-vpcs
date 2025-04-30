# Single-NAT Standard IPv6 VPC with IPv4 Connectivity

This creates an IPv6 VPC with both Public and Private Subnets, and single NAT Gateway to provide NAT64 service all of the Public and Private Subnets in the respective AZs.

This utilizes an Egress-Only Internet Gateway. Originally NAT was invented to solve the problem of IPv4 address exhaustion, but it had the side benefit of isolating the networks behind NAT gateways from the Internet. With IPv6 there is no NAT and there are no IP address ranges reserved for non-routable networks. Everything is routable. The Egress-Only Internet Gateway brings back the network-isolation benefits of IPv4's NAT to IPv6 by creating a one-way door for Internet connections. Outbound connections are allowed while inbound connections are blocked.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_subnet_addrs"></a> [private\_subnet\_addrs](#module\_private\_subnet\_addrs) | hashicorp/subnets/cidr | ~> 1.0 |
| <a name="module_public_subnet_addrs"></a> [public\_subnet\_addrs](#module\_public\_subnet\_addrs) | hashicorp/subnets/cidr | ~> 1.0 |
| <a name="module_top_level_vpc_cidr_blocks"></a> [top\_level\_vpc\_cidr\_blocks](#module\_top\_level\_vpc\_cidr\_blocks) | hashicorp/subnets/cidr | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.default_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_default_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_default_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv4_cidr_block"></a> [ipv4\_cidr\_block](#input\_ipv4\_cidr\_block) | Minimal IPv4 CIDR block used for NAT | `string` | `"192.168.100.0/24"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for the resources | `string` | n/a | yes |
| <a name="input_subnet_az_count"></a> [subnet\_az\_count](#input\_subnet\_az\_count) | Number of Availability Zones to use for subnets in the VPC | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ipv6_cidr_blocks"></a> [private\_subnet\_ipv6\_cidr\_blocks](#output\_private\_subnet\_ipv6\_cidr\_blocks) | Private Subnet IPv6 CIDR Blocks |
| <a name="output_public_subnet_ipv6_cidr_blocks"></a> [public\_subnet\_ipv6\_cidr\_blocks](#output\_public\_subnet\_ipv6\_cidr\_blocks) | Public Subnet IPv6 CIDR Blocks |
| <a name="output_top_level_vpc_ipv6_cidr_blocks"></a> [top\_level\_vpc\_ipv6\_cidr\_blocks](#output\_top\_level\_vpc\_ipv6\_cidr\_blocks) | Top-Level IPv6 CIDR blocks in the VPC |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | IPv6 CIDR block for the VPC |
<!-- END_TF_DOCS -->