variable "ami" {
  default = {
    "ubuntu" = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    "owner"  = "099720109477"
  }
}

variable "instance" {
  default = {
    "type"            = "t2.micro"
    "name"            = "web-server"
    "user_data_path"  = "scripts/init.sh"
    "key_name"        = "my-terraform-key"
    "public_key_path" = "~/.ssh/terraform.pub"
  }
}

variable "region" {
  default = "us-east-1"
}

variable "ssh_allow_cidr_blocks" {
  type = list(string)
}
