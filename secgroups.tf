resource "aws_security_group" "terrakube_masters"{
  name = "terrakube-masters"
  vpc_id = aws_vpc.terrakube_vpc.id
   tags = {
    Name = "terrakube-masters-sg"
  }
}

resource "aws_security_group" "terrakube_workers"{
  name = "terrakube-workers"
  vpc_id = aws_vpc.terrakube_vpc.id
   tags = {
    Name = "terrakube-workers-sg"
  }
}

resource "aws_security_group_rule" "allow_masters_all_from_self" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  self = true
  security_group_id = aws_security_group.terrakube_masters.id
}
 
resource "aws_security_group_rule" "allow_masters_6443_from_everywhere" {
  type = "ingress"
  from_port = 6443
  to_port = 6443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.terrakube_masters.id
}

resource "aws_security_group_rule" "allow_masters_ssh_from_everywhere" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.terrakube_masters.id
}

resource "aws_security_group_rule" "allow_masters_all_from_workers" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id =  aws_security_group.terrakube_workers.id
  security_group_id = aws_security_group.terrakube_masters.id
}

resource "aws_security_group_rule" "allow_workers_ssh_from_everywhere" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.terrakube_workers.id
}

resource "aws_security_group_rule" "allow_workers_all_from_self" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  self = true
  security_group_id = aws_security_group.terrakube_workers.id
}

resource "aws_security_group_rule" "allow_workers_all_from_masters" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = -1
  source_security_group_id =  aws_security_group.terrakube_masters.id
  security_group_id = aws_security_group.terrakube_workers.id
}