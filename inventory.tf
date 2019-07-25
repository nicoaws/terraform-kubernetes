resource "local_file" "ansible_inventory_file" {

  content = <<-EOT
[ca]
${aws_instance.kube_master.0.public_dns} private_ip=${aws_instance.kube_master.0.private_ip}
[masters]
%{ for instance in aws_instance.kube_master ~}
${instance.public_dns} private_ip=${instance.private_ip}
%{ endfor ~}

[workers]
%{ for instance in aws_instance.kube_worker ~}
${instance.public_dns} private_ip=${instance.private_ip}
%{ endfor ~}

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=${var.private_key_path}
kubeapi_nlb_dns_name=${aws_lb.kubeapi_nlb.dns_name}
kubeapi_nlb_port=${var.kubeapi_port}
kubernetes_version=${var.kubernetes_version}
KUBERNETES_SAN=127.0.0.1,localhost,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
encryption_key=zSTFTBH9SIu1IXVtRFxju7kfjqEEkonP9lirbkFDTqQ=
EOT
  filename = "ansible/inventory"
}