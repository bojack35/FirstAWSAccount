data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.private[0].id

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = false

  tags = {
    Name = "demo-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}