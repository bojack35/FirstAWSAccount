terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Two AZs keeps it simple for learning.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Create 4 /24s inside your /16:
  # /16 + 8 = /24
  public_cidrs  = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1)]
  private_cidrs = [cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 3)]
}

############################
# VPC
############################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name}-vpc" }
}

############################
# IGW
############################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

############################
# Subnets (2 Public, 2 Private)
############################
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.name}-public-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = { Name = "${var.name}-private-${count.index + 1}" }
}

############################
# Route Tables
############################

# Public RT: 0.0.0.0/0 -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway (in public subnet 1)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.name}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.this]

  tags = { Name = "${var.name}-natgw" }
}

# Private RT: 0.0.0.0/0 -> NATGW (egress for private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt" }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


#### inspection VPC

resource "aws_vpc" "inspection_vpc" {
  cidr_block           = "172.16.32.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "inspection-vpc"
  }
}

resource "aws_subnet" "inspection_subnet_a" {
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = "172.16.32.0/26"
  availability_zone = "us-east-1a"

  tags = {
    Name = "inspection-subnet-a"
  }
}

resource "aws_subnet" "inspection_subnet_b" {
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = "172.16.32.64/26"
  availability_zone = "us-east-1b"

  tags = {
    Name = "inspection-subnet-b"
  }
}

resource "aws_route_table" "inspection_rt" {
  vpc_id = aws_vpc.inspection_vpc.id

  tags = {
    Name = "inspection-rt"
  }
}

resource "aws_route" "default_to_tgw" {
  route_table_id         = aws_route_table.inspection_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tgw_id
}

resource "aws_route_table_association" "subnet_a_assoc" {
  subnet_id      = aws_subnet.inspection_subnet_a.id
  route_table_id = aws_route_table.inspection_rt.id
}

resource "aws_route_table_association" "subnet_b_assoc" {
  subnet_id      = aws_subnet.inspection_subnet_b.id
  route_table_id = aws_route_table.inspection_rt.id
}
