data "aws_availability_zones" "available" {}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = ["amazon"]
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*x86_64-ebs"]
 }
 filter {
  name = "architecture"
  values = ["x86_64"]
 }
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

variable "kubeadm_token" {
  type = "string"
  default = ""
}