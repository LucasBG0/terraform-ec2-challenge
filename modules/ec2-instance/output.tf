output "public_dns" {
  value = aws_instance.web_server.public_dns
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
