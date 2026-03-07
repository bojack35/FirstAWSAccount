variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# For quick testing. Lock this down to *your* public IP/CIDR when you can.
variable "allowed_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the public EC2 (SSH/HTTP)."
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "region" {
  default = "us-east-1"
}
