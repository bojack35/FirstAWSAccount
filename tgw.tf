# ############################
# # Transit Gateway
# ############################

# resource "aws_ec2_transit_gateway" "this" {
#   description                     = "${var.name} transit gateway"
#   amazon_side_asn                 = 64512
#   auto_accept_shared_attachments  = "disable"
#   default_route_table_association = "enable"
#   default_route_table_propagation = "enable"
#   dns_support                     = "enable"
#   vpn_ecmp_support                = "enable"

#   tags = {
#     Name = "${var.name}-tgw"
#   }
# }

# ############################
# # TGW VPC Attachment
# ############################

# resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
#   transit_gateway_id = aws_ec2_transit_gateway.this.id
#   vpc_id             = aws_vpc.this.id

#   # Use one subnet per AZ for the attachment.
#   # If your 4 subnets are in 4 AZs, you can attach all 4.
#   # Here’s a safe default using the first 2:
#   subnet_ids = [
#     aws_subnet.this[0].id,
#     aws_subnet.this[1].id
#   ]

#   dns_support  = "enable"
#   ipv6_support = "disable"

#   tags = {
#     Name = "${var.name}-tgw-attach"
#   }
# }

# output "tgw_id" {
#   value = aws_ec2_transit_gateway.this.id
# }

# output "tgw_attachment_id" {
#   value = aws_ec2_transit_gateway_vpc_attachment.this.id
# }