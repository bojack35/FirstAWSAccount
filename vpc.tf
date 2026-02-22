# terraform {
#   required_version = ">= 1.5.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }

# resource "aws_vpc" "this" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = var.name
#   }
# }

# # Create 4 /24 subnets inside the /8.
# # cidrsubnet("10.0.0.0/8", 16, n) -> /24 because 8 + 16 = 24
# resource "aws_subnet" "this" {
#   count = 4

#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "${var.name}-subnet-${count.index + 1}"
#   }
# }