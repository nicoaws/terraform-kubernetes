output ssh-master-leader-command {
  value = ["${format(format("ssh -i %s ec2-user@%%s", var.private_key_path), aws_instance.kube-master-leader.public_ip)}"]
}
output ssh-master-command {
  value = ["${formatlist(format("ssh -i %s ec2-user@%%s", var.private_key_path), aws_instance.kube-master.*.public_ip)}"]
}

output join-command {
  value = ["${formatlist(format("kubeadm join %%s:6443 --token %s --discovery-token-unsafe-skip-ca-verification", var.kubeadm_token), aws_network_interface.kube-master-internal-leader-eth.private_ips)}"]
}

# kubeadm join 10.0.0.21:6443 --token 1sxf09.xni3sie720hkzkb0 \                                                                                                                                                                                             
#     --discovery-token-ca-cert-hash sha256:8d9c71f16f40dbbd36e89442ebbe93e03a06f26c23f8ea9ddecf29ff9293d712  

#     --apiserver-advertise-address