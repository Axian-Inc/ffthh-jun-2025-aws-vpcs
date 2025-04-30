#!/usr/bin/env python3
'''
Create a network diagram of a VPC using the graphviz dot utility.
'''

import sys
import os.path
import boto3
import botocore
import pydot
from argparse import ArgumentParser

SUPPORTED_FILE_TYPES=[".dot",".gv",".jpg",".pdf",".png",".svg"]
DEFAULT_FILE_TYPE = ".png"

# Base Classes --------------------------------------------------------

class AwsResourceNodeBase(pydot.Node):
    '''
    Base Class for all AWS Resource Types
    '''
    def __init__(self,resource_description,id_key,resource_title):
        self.__resource_description = resource_description
        self.__resource_title = resource_title
        self.__node_name = resource_description[id_key]
        pydot.Node.__init__(self,self.__node_name,label=self._generate_aws_label(),shape="box")

    def _get_aws_description(self):
        '''
        Return the raw description for the AWS resource.
        '''
        return self.__resource_description

    def _get_aws_name(self):
        '''
        The the value for the 'Name' tag, if any. This assumes the EC2 way of
        tagging things, which is fine because everything here is under the EC2
        umbrella.
        '''
        name = None
        if 'Tags' in self.__resource_description:
            tags = self.__resource_description['Tags']
            for tag in tags:
                if tag['Key'] == "Name":
                    name = tag['Value']
                    break
        return name

    def _generate_aws_label_list(self):
        '''
        Generated a list of strings that should be in the node's label
        (often overridden in derived classes)
        '''
        label_list = [self.__resource_title]

        name = self._get_aws_name()
        if name is not None:
            label_list.append(name)

        label_list.append(self.__node_name)

        return label_list

    def _generate_aws_label(self):
        '''
        Turn the label list in to a single string for the node's label.
        '''
        return "\n".join(self._generate_aws_label_list())

class AwsCidrBlockNodeBase(AwsResourceNodeBase):
    '''
    Base class for VPCs and Subnets, things having IPv4 and IPv6 CIDR blocks
    '''
    def __init__(self,resource_description,id_key,resource_title):
        AwsResourceNodeBase.__init__(self,resource_description,id_key,resource_title)

    def _generate_aws_label_list(self):
        '''
        Enhance the parent class label list with the CIDR blocks
        '''
        label_list = AwsResourceNodeBase._generate_aws_label_list(self)

        resource_description = self._get_aws_description()

        cidr_block_list = []

        if 'CidrBlock' in resource_description:
            cidr_block_list.append(resource_description['CidrBlock'])

        if "CidrBlockAssociationSet" in resource_description:
            for association_set in resource_description["CidrBlockAssociationSet"]:
                if association_set["CidrBlockState"]["State"] == "associated":
                    cidr_block_list.append(association_set['CidrBlock'])

        if "Ipv6CidrBlockAssociationSet" in resource_description:
            for association_set in resource_description["Ipv6CidrBlockAssociationSet"]:
                if association_set["Ipv6CidrBlockState"]["State"] == "associated":
                    cidr_block_list.append(association_set['Ipv6CidrBlock'])

        label_list.extend(list(set(cidr_block_list)))

        return label_list

class AwsGatewayNodeBase(AwsResourceNodeBase):
    '''
    Base class for gateway resources, i.e. resources that are destinations
    in route tables.
    '''
    def __init__(self,resource_description,id_key,resource_title):
        AwsResourceNodeBase.__init__(self,resource_description,id_key,resource_title)

    def add_route_table_edges(self,graph,route_table_nodes):
        '''
        Create a pydot Edge between this node and any route tables that point
        to this gateway.
        '''
        for route_table_node in route_table_nodes:
            destinations = route_table_node.get_destinations_for_id(self.get_name())
            if len(destinations) > 0:
                label=",".join(destinations)
                graph.add_edge(NodeEdge(route_table_node,self,label=label))

# Conveniences --------------------------------------------------------

class NodeEdge(pydot.Edge):
    '''
    Convenience wrapper around the pydot.Edge class:
    - Operates on pydot.Node objects instead of node names.
    - Has hard-coded 'color' and 'dir' settings.
    '''
    def __init__(self,node_a,node_b,**kwargs):
        pydot.Edge.__init__(self,
            node_a.get_name(), node_b.get_name(),color="black", dir="forward",**kwargs)

# AWS Resource Classes ------------------------------------------------

class VpcNode(AwsCidrBlockNodeBase):
    '''
    AWS VPC
    '''
    def __init__(self,vpc_description):
        AwsCidrBlockNodeBase.__init__(self,vpc_description,"VpcId","VPC")

class SubnetNode(AwsCidrBlockNodeBase):
    '''
    AWS VPC Subnet
    '''
    def __init__(self,subnet_description):
        AwsCidrBlockNodeBase.__init__(self,subnet_description,"SubnetId","Subnet")

class RouteTableNode(AwsResourceNodeBase):
    '''
    AWS Route Table
    '''
    def __init__(self,routetable_description):
        AwsResourceNodeBase.__init__(self,routetable_description,"RouteTableId","Route Table")

    def is_main(self):
        '''
        Is this the main route table, i.e. the one automatically created by
        AWS as the default for the VPC?
        '''
        route_table_description = self._get_aws_description()

        for association in route_table_description["Associations"]:
            if association["Main"]:
                return True

        return False

    def is_associated_with(self,subnet_id):
        '''
        Is this route table associated with the specified subnet?
        '''
        route_table_description = self._get_aws_description()

        for association in route_table_description["Associations"]:
            if "SubnetId" in association and association["SubnetId"] == subnet_id:
                return True

        return False

    def _generate_aws_label_list(self):
        '''
        Enhance the parent class label list with note about this being the
        main route table, if that is the case.
        '''
        label_list = AwsResourceNodeBase._generate_aws_label_list(self)

        if self.is_main():
            label_list.append("(Main)")

        return label_list

    def get_destinations_for_id(self,gateway_id):
        '''
        Get list of route table destinations (usually CIDR Blocks) for the
        specified gateway ID
        '''
        destinations = []

        route_table_description = self._get_aws_description()
        route_descriptions = route_table_description['Routes']

        for route in route_descriptions:
            is_match = False
            for k,v in route.items():
                if k.endswith('Id') and v == gateway_id:
                    is_match = True
                    break
            if is_match:
                for k,v in route.items():
                    if k.startswith("Destination"):
                        destinations.append(v)

        return list(set(destinations))

class InternetGatewayNode(AwsGatewayNodeBase):
    '''
    AWS Internet Gateway
    '''
    def __init__(self,gateway_description):
        AwsGatewayNodeBase.__init__(self,gateway_description,"InternetGatewayId","Internet Gateway")

class EgressOnlyInternetGatewayNode(AwsGatewayNodeBase):
    '''
    AWS Egress-Only Internet Gateway
    '''
    def __init__(self,gateway_description):
        AwsGatewayNodeBase.__init__(self,gateway_description,"EgressOnlyInternetGatewayId","Egress-Only Internet Gateway")

class NatGatewayNode(AwsGatewayNodeBase):
    '''
    AWS NAT Gateway
    '''
    def __init__(self,gateway_description):
        AwsGatewayNodeBase.__init__(self,gateway_description,"NatGatewayId","NAT Gateway")

class VpcPeeringConnectionNode(AwsGatewayNodeBase):
    '''
    AWS VPC Peering Connection
    '''
    def __init__(self,gateway_description,is_requester):
        self._is_requester = is_requester
        AwsGatewayNodeBase.__init__(self,gateway_description,"VpcPeeringConnectionId","VPC Peering Connection")

    def _generate_aws_label_list(self):
        '''
        Enhance the parent class label list with item about this being the
        requester or the accepter.
        '''
        label_list = AwsResourceNodeBase._generate_aws_label_list(self)

        if self._is_requester:
            label_list.append("(Requester)")
        else:
            label_list.append("(Accepter)")

        return label_list

    def get_remote_vpc_node(self):
        '''
        Generate a node object representing the VPC at the other end of the
        VPC Peering Connection.
        '''
        remote_vpc_node = None
        peering_connection_description = self._get_aws_description()

        if self._is_requester:
            remote_vpc_node = RemoteVpcNode(peering_connection_description['AccepterVpcInfo'],is_requester=False)
        else:
            remote_vpc_node = RemoteVpcNode(peering_connection_description['RequesterVpcInfo'],is_requester=True)

        return remote_vpc_node

class VpnGatewayNode(AwsGatewayNodeBase):
    '''
    AWS VPN Gateway
    '''
    def __init__(self,gateway_description):
        AwsGatewayNodeBase.__init__(self,gateway_description,"VpnGatewayId","VPN Gateway")

class VpnConnectionNode(AwsResourceNodeBase):
    '''
    AWS VPN Connection
    '''
    def __init__(self,gateway_description):
        AwsResourceNodeBase.__init__(self,gateway_description,"VpnConnectionId","VPN Connection")

class TransitGatewayNode(AwsGatewayNodeBase):
    '''
    AWS Transit Gateway
    '''
    def __init__(self,gateway_description):
        AwsGatewayNodeBase.__init__(self,gateway_description,"TransitGatewayId","Transit Gateway")

class TransitGatewayAttachmentNode(AwsGatewayNodeBase):
    '''
    AWS Transit Gateway Attachment
    '''
    def __init__(self,attachment_description):
        AwsGatewayNodeBase.__init__(self,attachment_description,"TransitGatewayAttachmentId","Transit Gateway Attachment")

class RemoteNetworkNode(TransitGatewayAttachmentNode):
    '''
    Remote Network - A different presentation of a Transit Gateway Attachment
    '''
    def __init__(self,attachment_description):
        TransitGatewayAttachmentNode.__init__(self,attachment_description)

    def _generate_aws_label_list(self):
        '''
        Replace the labels that would normally be provided for the Transit
        Gateway Attachment itself, with just the info for the associated remote
        network.
        '''
        label_list = ['Remote Network']
        transit_gateway_attachment_description = self._get_aws_description()

        for key in ['ResourceType','ResourceOwnerId','ResourceId']:
            if key in transit_gateway_attachment_description:
                label_list.append(transit_gateway_attachment_description[key])

        return label_list

# External Resources

class TheInternetNode(pydot.Node):
    '''
    Node representing the public Internet
    '''
    def __init__(self):
        pydot.Node.__init__(self,"internet",label="The Internet",shape="ellipse")

class RemoteVpcNode(pydot.Node):
    '''
    Node representing the VPC at the other end of a VPC Peering Connection
    '''
    def __init__(self,remote_vpc_description,is_requester):
        remote_vpc_id = remote_vpc_description['VpcId']
        label_strings = ['Remote VPC']

        label_strings.append(remote_vpc_description['OwnerId'])
        label_strings.append(remote_vpc_id)

        if 'CidrBlockSet' in remote_vpc_description:
            for cidr_block_set in remote_vpc_description['CidrBlockSet']:
                label_strings.append(cidr_block_set['CidrBlock'])
        if 'Ipv6CidrBlockSet' in remote_vpc_description:
            for cidr_block_set in remote_vpc_description['Ipv6CidrBlockSet']:
                label_strings.append(cidr_block_set['Ipv6CidrBlock'])

        if is_requester:
            label_strings.append("(Requester)")
        else:
            label_strings.append("(Accepter)")

        pydot.Node.__init__(self,remote_vpc_id,label="\n".join(label_strings),shape="box")

# Get to work ---------------------------------------------------------

def main():
    '''
    Main entry point
    '''
    parser = ArgumentParser(
        description = "Generate a network diagram of an AWS VPC",
        epilog = f"Supported file types: {' '.join(SUPPORTED_FILE_TYPES)}"
    )
    parser.add_argument("--profile",
        help="AWS Profile")
    parser.add_argument("--region",
        help="AWS Region")
    parser.add_argument("--internet",action='store_true',
        help="Show the Internet (Warning: can make the graph hard to follow)")
    parser.add_argument("vpcid",
        help="AWS VPC ID, Name, or 'default' for the default VPC")
    parser.add_argument("filename", nargs='?',
        help=f"Name of the output file (default: vpcid{DEFAULT_FILE_TYPE})")
    args = parser.parse_args()

    if args.filename is None:
        args.filename = f"{args.vpcid}{DEFAULT_FILE_TYPE}"

    if os.path.exists(args.filename):
        sys.stderr.write(f"ERROR - file already exists: {args.filename}\n")
        sys.exit(1)

    extension = os.path.splitext(args.filename)[1]
    if extension not in SUPPORTED_FILE_TYPES:
        sys.stderr.write(f"ERROR - unsupported file type: {extension}\n")
        sys.exit(1)

    session = boto3.session.Session(profile_name=args.profile,region_name=args.region)
    ec2_client = session.client("ec2")

    # Collect Data and Create the Graph -------------------------------

    graph = pydot.Dot("vpc_network_graph", graph_type="graph", bgcolor="white", rankdir="LR")

    # The Internet
    if args.internet:
        the_internet_node = TheInternetNode()
        graph.add_node(the_internet_node)
    else:
        the_internet_node = None

    # VPC
    vpc_description = get_vpc_description(ec2_client,args.vpcid)
    vpc_node = VpcNode(vpc_description)
    graph.add_node(vpc_node)

    # Subnets
    response = ec2_client.describe_subnets( Filters=[{"Name": "vpc-id", "Values": [vpc_node.get_name()]}] )
    subnet_nodes = []
    for subnet_description in response["Subnets"]:
        subnet_node = SubnetNode(subnet_description)
        subnet_nodes.append(subnet_node)
        graph.add_node(subnet_node)
        graph.add_edge(NodeEdge(vpc_node,subnet_node))

    # Route Tables
    route_table_nodes = []
    main_route_table_node = None
    response = ec2_client.describe_route_tables( Filters=[{"Name": "vpc-id", "Values": [vpc_node.get_name()]}] )
    for route_table_description in response["RouteTables"]:
        route_table_node = RouteTableNode(route_table_description)
        route_table_nodes.append(route_table_node)
        if route_table_node.is_main():
            main_route_table_node = route_table_node
        graph.add_node(route_table_node)

    # Edges between Subnets and Route Tables
    associated_subnet_ids = []
    for route_table_node in route_table_nodes:
        for subnet_node in subnet_nodes:
            if route_table_node.is_associated_with(subnet_node.get_name()):
                graph.add_edge(NodeEdge(subnet_node,route_table_node))
                associated_subnet_ids.append(subnet_node.get_name())

    # Any subnet without an explicit route-table association gets associated
    # with the main route table.
    for subnet_node in subnet_nodes:
        if not subnet_node.get_name() in associated_subnet_ids:
            graph.add_edge(NodeEdge(subnet_node,main_route_table_node))

    # Internet Gateways
    response = ec2_client.describe_internet_gateways( Filters=[{"Name": "attachment.vpc-id", "Values": [vpc_node.get_name()]}] )
    for internet_gateway_description in response['InternetGateways']:
        internet_gateway_node = InternetGatewayNode(internet_gateway_description)
        graph.add_node(internet_gateway_node)
        internet_gateway_node.add_route_table_edges(graph,route_table_nodes)
        if the_internet_node is not None:
            graph.add_edge(NodeEdge(internet_gateway_node,the_internet_node))

    # Egress-Only Internet Gateways
    egress_only_internet_gateway_descriptions = get_egress_only_internet_gateway_descriptions(ec2_client,vpc_node.get_name())
    for egress_only_internet_gateway_description in egress_only_internet_gateway_descriptions:
        egress_only_internet_gateway_node = EgressOnlyInternetGatewayNode(egress_only_internet_gateway_description)
        graph.add_node(egress_only_internet_gateway_node)
        egress_only_internet_gateway_node.add_route_table_edges(graph,route_table_nodes)
        if the_internet_node is not None:
            graph.add_edge(NodeEdge(internet_gateway_node,the_internet_node))

    # NAT Gateways
    response = ec2_client.describe_nat_gateways( Filters=[{"Name": "vpc-id", "Values": [vpc_node.get_name()]}] )
    for nat_gateway_description in response['NatGateways']:
        nat_gateway_node = NatGatewayNode(nat_gateway_description)
        graph.add_node(nat_gateway_node)
        nat_gateway_node.add_route_table_edges(graph,route_table_nodes)
        if the_internet_node is not None:
            graph.add_edge(NodeEdge(nat_gateway_node,the_internet_node))

    # Accepter VPC Peering Connections
    response = ec2_client.describe_vpc_peering_connections( Filters=[{"Name": "accepter-vpc-info.vpc-id", "Values": [vpc_node.get_name()]}] )
    for vpc_peering_connections_description in response['VpcPeeringConnections']:
        vpc_peering_connection_node = VpcPeeringConnectionNode(vpc_peering_connections_description,is_requester=False)
        graph.add_node(vpc_peering_connection_node)
        vpc_peering_connection_node.add_route_table_edges(graph,route_table_nodes)
        remote_vpc_node = vpc_peering_connection_node.get_remote_vpc_node()
        graph.add_node(remote_vpc_node)
        graph.add_edge(NodeEdge(vpc_peering_connection_node,remote_vpc_node))

    # Requester VPC Peering Connections
    response = ec2_client.describe_vpc_peering_connections( Filters=[{"Name": "requester-vpc-info.vpc-id", "Values": [vpc_node.get_name()]}] )
    for vpc_peering_connections_description in response['VpcPeeringConnections']:
        vpc_peering_connection_node = VpcPeeringConnectionNode(vpc_peering_connections_description,is_requester=True)
        graph.add_node(vpc_peering_connection_node)
        vpc_peering_connection_node.add_route_table_edges(graph,route_table_nodes)
        remote_vpc_node = vpc_peering_connection_node.get_remote_vpc_node()
        graph.add_node(remote_vpc_node)
        graph.add_edge(NodeEdge(vpc_peering_connection_node,remote_vpc_node))

    # VPN Gateways
    response = ec2_client.describe_vpn_gateways( Filters=[{"Name": "attachment.vpc-id", "Values": [vpc_node.get_name()]}] )
    for vpn_gateway_description in response['VpnGateways']:
        vpn_gateway_node = VpnGatewayNode(vpn_gateway_description)
        graph.add_node(vpn_gateway_node)
        vpn_gateway_node.add_route_table_edges(graph,route_table_nodes)
        response_c = ec2_client.describe_vpn_connections( Filters=[{"Name": "vpn-gateway-id", "Values": [vpn_gateway_node.get_name()]}])
        for vpn_connection_description in response_c['VpnConnections']:
            vpn_connection_node = VpnConnectionNode(vpn_connection_description)
            graph.add_node(vpn_connection_node)
            graph.add_edge(NodeEdge(vpn_gateway_node,vpn_connection_node))

    # Transit Gateways
    transit_gateway_descriptions = get_transit_gateway_descriptions_for_vpc(ec2_client,vpc_node.get_name())
    for transit_gateway_description in transit_gateway_descriptions:
        transit_gateway_node = TransitGatewayNode(transit_gateway_description)
        graph.add_node(transit_gateway_node)
        transit_gateway_node.add_route_table_edges(graph,route_table_nodes)
        transit_gateway_attachment_descriptions = get_transit_gateway_attachement_descriptions_for_transit_gateway(ec2_client,transit_gateway_node.get_name(),vpc_node.get_name())
        for transit_gateway_attachment_description in transit_gateway_attachment_descriptions:
            remote_network_node = RemoteNetworkNode(transit_gateway_attachment_description)
            graph.add_node(remote_network_node)
            graph.add_edge(NodeEdge(transit_gateway_node,remote_network_node))
    
    # TODO:
    # - Carrier Gateways

    # Save to file ----------------------------------------------------

    if extension == ".gv":
        # .gv is the preferred extension for graphviz dot files in order
        # to avoid confusion with MS Word document templates.
        write_method_name = "write_dot"
    else:
        ftype = extension[1:]
        write_method_name = f"write_{ftype}"
    getattr(graph,write_method_name)(args.filename)
    print(f"File created: {args.filename}")

def get_vpc_description(ec2_client,vpc_id_or_name):
    '''
    Get a VPC's description by VPC ID, Name, or the special name of "default"
    '''

    if vpc_id_or_name.startswith("vpc-"):
        filters = [{"Name": "vpc-id", "Values": [vpc_id_or_name]}]
    elif vpc_id_or_name == "default":
        filters = [{"Name": "isDefault", "Values": ["true"]}]
    else:
        filters = [{"Name": "tag:Name", "Values": [vpc_id_or_name]}]

    try:
        response = ec2_client.describe_vpcs( Filters = filters )
        vpc_descriptions = response["Vpcs"]
    except botocore.exceptions.ClientError as e:
        if 'NotFound' in str(e):
            sys.stderr.write(f"ERROR - VPC not found: {vpc_id_or_name}\n")
            sys.exit(1)
        else:
            raise

    if len(vpc_descriptions) > 1:
        sys.stderr.write(f"ERROR - Found more than one VPC matching '{vpc_id_or_name}'. Use ID instead.\n")
        sys.exit(1)

    return vpc_descriptions[0]

def get_egress_only_internet_gateway_descriptions(ec2_client,vpc_id):
    '''
    Get the descriptions for egress-only internet gateways that are associated
    with the specified VPC. The AWS API does not support filtering by VPC ID
    so we have to do our own filtering.
    '''
    egress_only_internet_gateway_descriptions = []
    response = ec2_client.describe_egress_only_internet_gateways()
    for egress_only_internet_gateway_description in response['EgressOnlyInternetGateways']:
        for attachment in egress_only_internet_gateway_description['Attachments']:
            if attachment['VpcId'] == vpc_id:
                egress_only_internet_gateway_descriptions.append(egress_only_internet_gateway_description)
                break

    return egress_only_internet_gateway_descriptions

def get_transit_gateway_descriptions_for_vpc(ec2_client,vpc_id):
    '''
    Get the transit gateways assciated with the VPC. It's a two-step process
    via transit gateway attachments.
    '''

    response = ec2_client.describe_transit_gateway_attachments(
        Filters=[
            {"Name": "resource-type", "Values": ["vpc"]},
            {"Name": "resource-id", "Values": [vpc_id]}
        ])

    transit_gateway_ids = []
    for transit_gateway_attachment_description in response['TransitGatewayAttachments']:
        transit_gateway_ids.append(transit_gateway_attachment_description['TransitGatewayId'])

    response = ec2_client.describe_transit_gateways(TransitGatewayIds=transit_gateway_ids)
    return response['TransitGateways']

def get_transit_gateway_attachement_descriptions_for_transit_gateway(ec2_client,transit_gateway_id,vpc_id):
    '''
    Get the Transit Gateway Attachment descriptions associated withe the specified
    Transit Gateway ID, but excluding any that are for the specified VPC ID.
    '''
    response = ec2_client.describe_transit_gateway_attachments(
        Filters=[
            {"Name": "transit-gateway-id", "Values": [transit_gateway_id]}
        ])

    all_transit_gateway_attachment_descriptions = response['TransitGatewayAttachments']
    transit_gateway_attachment_descriptions = []

    for transit_gateway_attachment_description in all_transit_gateway_attachment_descriptions:
        if transit_gateway_attachment_description['ResourceType'] == 'vpc' \
            and transit_gateway_attachment_description['ResourceId'] == vpc_id:
            continue
        transit_gateway_attachment_descriptions.append(transit_gateway_attachment_description)

    return transit_gateway_attachment_descriptions

main()
