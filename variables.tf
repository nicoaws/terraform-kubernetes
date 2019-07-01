data "aws_availability_zones" "available" {}

variable "ubuntu_ami" {
  type = "string"
  description = "ami id for ubuntu 18-04-server"
  default = "ami-08d658f84a6d84a80"
}

variable "instance_type" {
  type = "string"
  default = "t3a.micro"
}

variable "vpc_cidr" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "terrakube-public-subnet-range" {
  type = "string"
  default = "10.0.0.0/23"
}

variable "terrakube-private-subnet-range" {
  type = "string"
  default = "10.0.128.0/23"
}

variable "public_key_path" {
  type = "string"
  default = ""
}

variable "private_key_path" {
  type = "string"
  default = ""
}

variable "master_count" {
  type = "string"
  default = 3
}

variable "worker_count" {
  type = "string"
  default = 5
}
