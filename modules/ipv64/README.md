# IPv6 NAT64 VPCs

These modules manage IPv6 VPCs that utilize NAT64 and DNS64 for access to IPv4-only destinations.

* [basic](./basic) - Basic VPC, Public Subnets only, with one NAT Gateway per AZ for the respective Subnets.
* [basic1n](./basic1n) - Like the above, but with single NAT Gateway shared by all Subnets.
* [standard](./standard) - Standard VPC with both Public and Private Subnets, with one NAT Gateway per AZ for the respective Public and Private Subnets, and an Egress-Only Internet Gateway for the Private Subnets
* [standard1n](./standard1n) - Like the above, but with just one NAT Gateway shared by all Subnets.
