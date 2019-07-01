output ssh-master-string {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.kube-master.public_ip}"
}