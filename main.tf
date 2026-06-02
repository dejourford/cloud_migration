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
    description = "Allows SSH from inside VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
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

  ingress {
    description = "Allows traffic to port 5000 from my IP"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ssh_cidr}"]
  }

  ingress {
    description = "Allows traffic to port 32649 from my IP for Kubernetes"
    from_port        = 32649
    to_port          = 32649
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ssh_cidr}"]
  }

  ingress {
    description = "Allows traffic to port 5000 from my IP for Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ssh_cidr}", "192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20"]
  }

  ingress {
    description = "Allows traffic to port 5000 from my IP for Jenkins"
    from_port        = 50000
    to_port          = 50000
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ssh_cidr}"]
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
# IAM USER
#----------------------------------------------#

resource "aws_iam_user" "dev_dejour_ford" {
  name = "dejour.ford"
  path = "/users/"
  force_destroy = true

  tags = {
    environment = "dev"
    team = "engineering"
    email = "dejour.ford@company.com"
  }
}

resource "aws_iam_access_key" "dev_access_key" {
  user = aws_iam_user.dev_dejour_ford.name
}


#----------------------------------------------#
# IAM GROUP
#----------------------------------------------#

resource "aws_iam_group" "dev_group" {
  name = "developers"
}

resource "aws_iam_group_membership" "dev_group_members" {
  name  = "dev-group-members"
  group = aws_iam_group.dev_group.name
  users = [aws_iam_user.dev_dejour_ford.name]
  
}

#----------------------------------------------#
# IAM POLICY
#----------------------------------------------#

data "aws_iam_policy_document" "dev_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = ["*"]
  }

   statement {
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetAccountPasswordPolicy",
      "iam:GetUser",
      "iam:ListMFADevices"
    ]
    resources = ["*"]
  }

}

data "aws_iam_policy_document" "require_mfa" {
  statement {
    effect    = "Deny"
    not_actions = [
      "iam:ChangePassword",
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetAccountPasswordPolicy",
      "iam:GetUser",
      "iam:ListMFADevices"
    ]
    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_group_policy" "dev_policy" {
  name   = "dev-ec2-policy"
  group  = aws_iam_group.dev_group.name
  policy = data.aws_iam_policy_document.dev_policy.json
}

resource "aws_iam_group_policy" "require_mfa" {
  name   = "require-mfa"
  group  = aws_iam_group.dev_group.name
  policy = data.aws_iam_policy_document.require_mfa.json
}

resource "aws_iam_group_policy_attachment" "s3_readonly" {
  group      = aws_iam_group.dev_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#----------------------------------------------#
# PASSWORD POLICY
#----------------------------------------------#

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true

  
}

#----------------------------------------------#
# LOGIN PROFILE
#----------------------------------------------#

resource "aws_iam_user_login_profile" "dev_dejour_ford" {
  user                    = aws_iam_user.dev_dejour_ford.name
  password_reset_required = true
}


#----------------------------------------------#
# SSM PERMISSIONS
#----------------------------------------------#

resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
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
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = aws_key_pair.key.key_name
  instance_name        = "${var.project_name}-ec2-${count.index + 1}"
}

#----------------------------------------------#
# S3 BUCKET
#----------------------------------------------#

resource "aws_s3_bucket" "s3" {
  bucket = "${var.project_name}-bucket-${var.aws_account_id}"

  tags = {
    Name        = "${var.project_name}-bucket-${var.aws_account_id}"
    Environment = "Dev"
  }
}
