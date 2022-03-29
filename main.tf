terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

################## Configure the AWS Provider
provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami.ubuntu}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.ami.owner}"]
}

################## A key pair is used to control login access to EC2 Instances
resource "aws_key_pair" "web_server" {
  key_name   = var.instance.key_name
  public_key = file(var.instance.public_key_path)
}

################## Modules
module "sg" {
  source           = "./modules/security-group"
  ipv4_cidr_blocks = var.ssh_allow_cidr_blocks
}

module "ec2" {
  source        = "./modules/ec2-instance"
  instance_type = var.instance.type
  ami_id        = data.aws_ami.ubuntu.id
  key_name      = var.instance.key_name
  sg_ids        = ["${module.sg.vpc_security_group_id}"]
  instance_name = var.instance.name
  user_data     = var.instance.user_data_path
  bucket = {
    name   = aws_s3_bucket.storage.id
    object = aws_s3_object.react_app.id
  }
}

################## Bucket
resource "aws_s3_bucket" "storage" {
  bucket = "terraform-challenge-storage"

  tags = {
    Name = "Terraform Storage"
  }
}

resource "aws_s3_bucket_acl" "storage" {
  bucket = aws_s3_bucket.storage.id
  acl    = "private"
}

resource "aws_s3_object" "react_app" {
  bucket       = aws_s3_bucket.storage.id
  key          = "react-app.deb"
  source       = "scripts/react-app.deb"
  etag         = filemd5("scripts/react-app.deb")
  content_type = "application/vnd.debian.binary-package"
  acl          = "public-read"
}
