data "template_file" "cloud_init_master" {
  template = "${file("scripts/cloud-init-master.sh")}"
}

data "template_cloudinit_config" "cloud_init_master_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.cloud_init_master.rendered}"
  }
}


data "template_file" "kube_worker_csr_generator_template" {
  count = var.worker_count
  vars = {
    HOSTNAME = "terrakube-worker-${count.index}"
    EXTERNAL_IP = element(aws_instance.kube-worker.*.private_ip, count.index)
    INTERNAL_IP = element(aws_instance.kube-worker.*.public_ip, count.index)
  }
  template = file("ca-config/kube-worker-csr-generator.template")
}