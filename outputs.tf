output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  value = [for s in aws_subnet.this : s.id]
}

output "subnet_cidrs" {
  value = [for s in aws_subnet.this : s.cidr_block]
}

output "subnet_azs" {
  value = [for s in aws_subnet.this : s.availability_zone]
}