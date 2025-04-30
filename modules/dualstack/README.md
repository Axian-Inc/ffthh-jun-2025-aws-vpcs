# Dual-stacks VPCs

These modules manage dual-stack VPCs that support both IPv4 and IPv6.

* [basic](./basic) - Basic VPC, Public Subnets only.
* [standard](./standard) - Standard VPC with both Public and Private Subnets, with one NAT Gateway per AZ for IPv4 in the respective Private Subnets, and an Egress-Only Internet Gateway for IPv6 in the Private Subnets.
* [standard1n](./standard1n) - Like the above, but with just one NAT Gateway shared by all Private Subnets.
