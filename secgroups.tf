resource "aws_security_group" "terrakube-private"{
  name = "terrakube-private"

  vpc_id = "${aws_vpc.terrakube-vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self = true
  }

  tags {
    Name = "terrakube-internal"
  }
}

resource "aws_security_group" "terrakube-public"{
  name = "terrakube-public"
  description = "Enable HTTPS and SSH traffic inbound"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = "${aws_vpc.terrakube-vpc.id}"

  tags {
    Name = "terrakube-public"
  }
}
