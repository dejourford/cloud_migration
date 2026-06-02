#----------------------------------------------#
# DATA SOURCE
#----------------------------------------------#

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#----------------------------------------------#
# COMPUTE (EC2)
#----------------------------------------------#

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name = var.key_name

  root_block_device {
    volume_size           = 20    # size in GB
    volume_type           = "gp3" # general purpose SSD
    delete_on_termination = true  # delete disk when EC2 is destroyed
    encrypted             = true  # encrypt the disk
  }

  tags = {
    Name = var.instance_name
  }
}
