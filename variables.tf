variable "project_name" {
    type = string
    default = "server"
}

variable "region" {
    type = string
    default = "us-east-2"
}

variable "allowed_ssh_cidr" {
    type = string
}

variable "any_ip" {
    type = string
}

variable "aws_account_id" {
    type = string
}
