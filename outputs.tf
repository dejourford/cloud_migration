output "EC2IpAddress" {
  value = module.ec2[*].public_ip
}

output "instance_ids" {
  value = module.ec2[*].instance_id
}

output "ssm_connect_command" {
  value = module.ec2[*].ssm_connect_command
}

output "dev_access_key_id" {
  value = aws_iam_access_key.dev_access_key.id
}

output "dev_secret_access_key" {
  value     = aws_iam_access_key.dev_access_key.secret
  sensitive = true
}

output "dev_initial_password" {
  value     = aws_iam_user_login_profile.dev_dejour_ford.password
  sensitive = true
}
