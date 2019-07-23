resource "local_file" "ansible_inventory_file" {

  content = <<-EOT
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

EOT
  filename = "ansible/inventory"
}