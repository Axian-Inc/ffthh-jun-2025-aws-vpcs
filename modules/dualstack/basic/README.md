# Basic Dual-Stack VPC

This creates a VPC that is similar to the default IPv4 VPCs provided by AWS but is for both IPv4 and IPv6.

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
| <a name="module_subnet_ipv4_addrs"></a> [subnet\_ipv4\_addrs](#module\_subnet\_ipv4\_addrs) | hashicorp/subnets/cidr | ~> 1.0 |
| <a name="module_subnet_ipv6_addrs"></a> [subnet\_ipv6\_addrs](#module\_subnet\_ipv6\_addrs) | hashicorp/subnets/cidr | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.default_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.these](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv4_cidr_block"></a> [ipv4\_cidr\_block](#input\_ipv4\_cidr\_block) | IPv4 CIDR block for the VPC | `string` | `"10.1.0.0/16"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Naming prefix for the resources | `string` | n/a | yes |
| <a name="input_subnet_az_count"></a> [subnet\_az\_count](#input\_subnet\_az\_count) | Number of Availability Zones to use for subnets in the VPC | `number` | `3` | no |
| <a name="input_subnet_ipv4_cidr_shift"></a> [subnet\_ipv4\_cidr\_shift](#input\_subnet\_ipv4\_cidr\_shift) | Number of bits to shift from the VPC IPv4 CIDR block to generate the subnet CIDR blocks | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_ipv4_cidr_blocks"></a> [subnet\_ipv4\_cidr\_blocks](#output\_subnet\_ipv4\_cidr\_blocks) | Subnet IPv4 CIDR Blocks |
| <a name="output_subnet_ipv6_cidr_blocks"></a> [subnet\_ipv6\_cidr\_blocks](#output\_subnet\_ipv6\_cidr\_blocks) | Subnet IPv6 CIDR Blocks |
| <a name="output_vpc_ipv4_cidr_block"></a> [vpc\_ipv4\_cidr\_block](#output\_vpc\_ipv4\_cidr\_block) | IPv4 CIDR block for the VPC |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | IPv6 CIDR block for the VPC |
<!-- END_TF_DOCS -->