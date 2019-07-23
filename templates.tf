data "template_file" "cloud_init" {
  template = file("scripts/cloud-init.sh")
}

data "template_cloudinit_config" "cloud_init_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.cloud_init.rendered}"
  }
}