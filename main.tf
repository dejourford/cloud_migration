#----------------------------------------------#
# VPC
#----------------------------------------------#

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#----------------------------------------------#
# PUBLIC SUBNET
#----------------------------------------------#

resource "aws_subnet" "sn" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-sn"
  }
}

#----------------------------------------------#
# INTERNET GATEWAY
#----------------------------------------------#

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-gw"
  }
}


#----------------------------------------------#
# ROUTE TABLE
#----------------------------------------------#

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

#----------------------------------------------#
# ROUTE TABLE ASSOCIATION
#----------------------------------------------#

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.sn.id
  route_table_id = aws_route_table.rt.id
}

#----------------------------------------------#
# SECURITY GROUPS
#----------------------------------------------#

resource "aws_security_group" "sg" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.main.id

   ingress {
    description = "Allows SSH from my IP only"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ssh_cidr}"]
  }

  ingress {
    description = "Allows HTTP from any IP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows HTTPS from any IP"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#----------------------------------------------#
# KEY PAIR
#----------------------------------------------#
resource "aws_key_pair" "key" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/my-project.pub")
}

#----------------------------------------------#
# COMPUTE (EC2)
#----------------------------------------------#

module "ec2" {
  source = "./modules/ec2"
  count = 1

  project_name         = var.project_name
  instance_type        = "t3.small"
  subnet_id            = aws_subnet.sn.id
  security_group_ids   = [aws_security_group.sg.id]
  key_name             = aws_key_pair.key.key_name
  instance_name        = "${var.project_name}-ec2-${count.index + 1}"
}
