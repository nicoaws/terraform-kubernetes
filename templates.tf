data "template_file" "cloud_init" {
  template = file("templates/cloud-init.sh")
  vars = {
    kubernetes_version = var.kubernetes_version
    go_version = var.go_version
  }
}

data "template_cloudinit_config" "cloud_init_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = data.template_file.cloud_init.rendered
  }
}

data "template_file" "hosts_data" {
  template = file("templates/hosts_data.tmpl")
  vars = { 
    MASTERS = jsonencode(aws_instance.kube_master.*)
    WORKERS = jsonencode(aws_instance.kube_worker.*)
    NLB_DNS_NAME = aws_lb.kubeapi_nlb.dns_name
    NLB_PORT = var.kubeapi_port
  }
}

resource "local_file" "hosts_data" {
  content = data.template_file.hosts_data.rendered
  filename = "kubernetes/hosts"
}