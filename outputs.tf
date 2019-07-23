output ssh-master-command {
  value = ["${formatlist(format("ssh -i %s ec2-user@%%s", var.private_key_path), aws_instance.kube_master.*.public_dns)}"]
}