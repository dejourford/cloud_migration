output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ssm_connect_command" {
  value = "aws ssm start-session --target ${aws_instance.ec2.id}"
}
