variable "ipv4_cidr_blocks" {
  type = list(string)
}

variable "name" {
  type    = string
  default = "web-server-and-ssh"
}

variable "description" {
  type    = string
  default = "Allow Web Server and SSH inbound traffic"
}
