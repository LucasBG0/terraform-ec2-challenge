variable "key_name" {
  type = string
}

variable "sg_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "my-instance"
}

variable "user_data" {
  type = string
}

variable "bucket" {
  type = map(string)
}
