############################
# TGW + Attachment + TGW Route Table
############################
resource "aws_ec2_transit_gateway" "this" {
  description                     = "${var.name} tgw"
  amazon_side_asn                 = 64512
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = { Name = "${var.name}-tgw" }
}

# Attach TGW to PRIVATE subnets (recommended)
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [for s in aws_subnet.private : s.id]

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = { Name = "${var.name}-tgw-attach" }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = { Name = "${var.name}-tgw-rt" }
}

# Associate the VPC attachment with the TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "vpc_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# Propagate VPC CIDR into the TGW route table (so other attachments can learn it)
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}



### inspection VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_attach" {

  subnet_ids = [
    aws_subnet.inspection_subnet_a.id,
    aws_subnet.inspection_subnet_b.id
  ]

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.inspection_vpc.id

  appliance_mode_support = "enable"

  tags = {
    Name = "inspection-vpc-attachment"
  }
}