# Basic IPv6 VPC

This creates an IPv6-only VPC that is similar to the default IPv4 VPCs provided by AWS, with just Public Subnets. Resources in this VPC do not have access to IPv4-only destinations.

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
| <a name="module_subnet_addrs"></a> [subnet\_addrs](#module\_subnet\_addrs) | hashicorp/subnets/cidr | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
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
| <a name="output_subnet_ipv6_cidr_blocks"></a> [subnet\_ipv6\_cidr\_blocks](#output\_subnet\_ipv6\_cidr\_blocks) | Subnet IPv6 CIDR Blocks |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | IPv6 CIDR block for the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC Name |
<!-- END_TF_DOCS -->
