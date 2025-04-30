# AWS VPC Examples using Terraform

Here find examples of creating AWS VPCs using Terraform. Included are fairly typical IPv4 VPCs which you have likely seen before, and then IPv6 and Dual-Stack VPCs which are still fairly rare.

The IPv6 and Dual-Stack VPCs include some AWS capabilities you might not have otherwise seen:

* NAT64/DNS64
* Egress-Only Internet Gateways

The [modules](./modules) directory contains reusable Terraform modules for VPCs. These could have been implemented as one gigantic module with what would have been a large number of options for controlling the type of VPC, but for educational purposes it seemed it would be much easier to understand as separate modules even though there is a lot of code duplication. Also, in this form it would be easier to migrate to a different IaC tool if you wanted to do that.

The [stacks](./stacks) directory contains Terraform stacks that leverage the modules. The variable settings are targeted for the Axian L&D account.

The [scripts](./scripts) directory contains a script for generating a network diagram of a VPC.
