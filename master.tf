resource "aws_instance" "kube-master-leader" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.terrakube-keypair.id}"
  subnet_id = "${aws_subnet.terrakube-public-subnets.0.id}"
  vpc_security_group_ids = ["${aws_security_group.terrakube-public.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-master-config.0.rendered}"
  associate_public_ip_address = true
  source_dest_check = false
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = "${file(var.private_key_path)}"
    }
  }
  tags = {
    Name = "terrakube-master-0"
  }
}

resource "aws_network_interface" "kube-master-internal-leader-eth" {
  subnet_id = "${aws_subnet.terrakube-private-subnets.0.id}"
  security_groups = ["${aws_security_group.terrakube-private.id}"]
  source_dest_check = false
  attachment {
    instance     = "${aws_instance.kube-master-leader.id}"
    device_index = 1
  }
}

resource "aws_instance" "kube-master" {
  depends_on = [ "aws_instance.kube-master-leader" ]
  count = "${var.master_count - 1}"
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.terrakube-keypair.id}"
  subnet_id = "${element(aws_subnet.terrakube-public-subnets.*.id, count.index + 1)}"
  vpc_security_group_ids = ["${aws_security_group.terrakube-public.id}"]
  user_data = "${element(data.template_cloudinit_config.cloud-init-master-config.*.rendered, count.index + 1)}"
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = "terrakube-master-${count.index + 1}"
  }
}

resource "aws_network_interface" "kube-master-internal-eth" {
  count = "${var.master_count - 1}"
  subnet_id = "${element(aws_subnet.terrakube-private-subnets.*.id,count.index + 1 )}"
  security_groups = ["${aws_security_group.terrakube-private.id}"]
  source_dest_check = false
  attachment {
    instance     = "${element(aws_instance.kube-master.*.id,count.index)}"
    device_index = 1
  }
}
