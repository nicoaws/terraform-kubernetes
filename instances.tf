resource "aws_instance" "kube_master" {
  count = var.master_count
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name = aws_key_pair.terrakube-keypair.id
  subnet_id = aws_subnet.terrakube_public_subnets.*.id[count.index]
  vpc_security_group_ids = [ aws_security_group.terrakube_masters.id ]
  user_data = data.template_cloudinit_config.cloud_init_config.rendered
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "terrakube-master-${count.index}"
  }
}


resource "aws_instance" "kube_worker" {
  count = var.worker_count
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name = aws_key_pair.terrakube-keypair.id
  subnet_id = element(aws_subnet.terrakube_public_subnets.*.id,count.index)
  vpc_security_group_ids = [ aws_security_group.terrakube_workers.id ]
  user_data = data.template_cloudinit_config.cloud_init_config.rendered
  associate_public_ip_address = true
  source_dest_check = false
  
  tags = {
    Name = "terrakube-worker-${count.index}"
  }
}

resource "null_resource" "kube_master_set_hostnames" {
  count = var.master_count
  triggers = {
    kube_master_ids = aws_instance.kube_master[count.index].id
  }
  connection {
    host = aws_instance.kube_master[count.index].public_dns
    user = "ec2-user"
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl set-hostname terrakube-master-${count.index}" ] 
  }
}

resource "null_resource" "kube_worker_set_hostnames" {
  count = var.worker_count
  triggers = {
    kube_worker_id = aws_instance.kube_worker[count.index].id
  }
  connection {
    host = aws_instance.kube_worker[count.index].public_dns
    user = "ec2-user"
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl set-hostname terrakube-worker-${count.index}" ] 
  }
}