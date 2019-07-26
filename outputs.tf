output ssh-master-command {
  value = ["${formatlist(format("ssh -i %s ec2-user@%%s", var.private_key_path), aws_instance.kube_master.*.public_dns)}"]
}

output ssh-worker-command {
  value = ["${formatlist(format("ssh -i %s ec2-user@%%s", var.private_key_path), aws_instance.kube_worker.*.public_dns)}"]
}

output nlb_dns_name {
  value = aws_lb.kubeapi_nlb.dns_name
}