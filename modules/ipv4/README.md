# IPv4 VPCs

These modules manage IPv4 VPCs.

* [basic](./basic) - Basic VPC, Public Subnets only.
* [standard](./standard) - Standard VPC with both Public and Private Subnets, with one NAT Gateway per AZ for the respective Private Subnets.
* [standard1n](./standard1n) - Like the above, but with just one NAT Gateway shared between all Private Subnets.
