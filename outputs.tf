output "EC2IpAddress" {
  value = module.ec2[*].public_ip
}

output "instance_ids" {
  value = module.ec2[*].instance_id
}

output "ssm_connect_command" {
  value = module.ec2[*].ssm_connect_command
}

