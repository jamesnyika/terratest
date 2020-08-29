output "public_instance_id" {
  value = aws_instance.dec2_nginx.id
}

output "public_instance_ip" {
  value = aws_instance.dec2_nginx.public_ip
}
