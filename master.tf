resource "aws_instance" "kube-master" {
  ami = "${var.ubuntu_ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.terrakube-keypair.id}"
  subnet_id = "${aws_subnet.terrakube-public-subnets.0.id}"
  vpc_security_group_ids = ["${aws_security_group.terrakube-public.id}"]
  user_data = "${file("scripts/userdata.sh")}"
  associate_public_ip_address = true
  source_dest_check = true
  tags = {
    Name = "terrakube-master"
  }

  

}

resource "aws_network_interface" "kube-master-internal-eth" {
  subnet_id = "${aws_subnet.terrakube-private-subnets.0.id}"
  security_groups = ["${aws_security_group.terrakube-private.id}"]

  attachment {
    instance     = "${aws_instance.kube-master.id}"
    device_index = 1
  }
}
