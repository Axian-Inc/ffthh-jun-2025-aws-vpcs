# Standard IPv4 VPC

This creates an IPv4 VPC has both Public and Private Subnets with a NAT Gateway in each AZ for the respective Private Subnets.

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
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | IPv4 CIDR block for the VPC | `string` | `"10.1.0.0/16"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for the resources | `string` | n/a | yes |
| <a name="input_private_cidr_block_shift"></a> [private\_cidr\_block\_shift](#input\_private\_cidr\_block\_shift) | Number of bits to shift from the VPC CIDR block to generate the private CIDR block | `number` | `1` | no |
| <a name="input_private_subnet_bit_shift"></a> [private\_subnet\_bit\_shift](#input\_private\_subnet\_bit\_shift) | Number of bits to shift from the private CIDR block to generate the private subnet CIDR blocks | `number` | `2` | no |
| <a name="input_public_cidr_block_shift"></a> [public\_cidr\_block\_shift](#input\_public\_cidr\_block\_shift) | Number of bits to shift from the VPC CIDR to generate the public CIDR block | `number` | `1` | no |
| <a name="input_public_subnet_bit_shift"></a> [public\_subnet\_bit\_shift](#input\_public\_subnet\_bit\_shift) | Number of bits to shift from the public CIDR block to generate the public subnet CIDR blocks | `number` | `2` | no |
| <a name="input_subnet_az_count"></a> [subnet\_az\_count](#input\_subnet\_az\_count) | Number of Availability Zones to use for the subnets | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#output\_private\_subnet\_cidr\_blocks) | Private Subnet IPv4 CIDR Blocks |
| <a name="output_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#output\_public\_subnet\_cidr\_blocks) | Public Subnet IPv4 CIDR Blocks |
| <a name="output_top_level_vpc_cidr_blocks"></a> [top\_level\_vpc\_cidr\_blocks](#output\_top\_level\_vpc\_cidr\_blocks) | Top-Level IPv4 CIDR blocks in the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | IPv4 CIDR block for the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC Name |
<!-- END_TF_DOCS -->