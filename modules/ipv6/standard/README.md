# Standard IPv6 VPC

This creates an IPv6-only VPC has both Public and Private Subnets. Resources in this VPC do not have access to IPv4-only destinations.

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
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.private_default_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_default_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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
