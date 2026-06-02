variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_ids" { type = list(string) }
variable "key_name" {}
variable "volume_size" { default = 20 }
variable "instance_name" {}
variable "project_name" {
    type = string
    default = "server"
}
